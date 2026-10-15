class_name PlayerController
extends CharacterBody3D
## Camera-relative locomotion. Ray queries areas on the Interactable layer.
signal interacted(target: Node)
@export var speed: float = 5.0
@export var rotation_speed: float = 12.0
@export var mouse_sensitivity: float = 0.003
var controls_enabled: bool = true
var target: Node3D
@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var ray: RayCast3D = $CameraPivot/SpringArm3D/Camera3D/InteractionRay
@onready var visual: Node3D = $Visual

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CameraPivot/SpringArm3D.add_excluded_object(get_rid())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not controls_enabled or GameFlow.transitioning:
		return
	if event is InputEventMouseButton and event.pressed and not event.is_echo():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		pivot.rotation.y -= event.relative.x * mouse_sensitivity
		pivot.rotation.x = clampf(pivot.rotation.x - event.relative.y * mouse_sensitivity, -0.9, 0.35)
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.physical_keycode == KEY_E and event.pressed and not event.echo):
		if is_instance_valid(target) and target.has_method("interact"):
			interacted.emit(target)
			target.interact(self)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 22.0 * delta
	var direction := Vector3.ZERO
	if controls_enabled and not GameFlow.transitioning:
		var axis := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		axis += Vector2(float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)), float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
		axis = axis.limit_length()
		direction = pivot.global_basis * Vector3(axis.x, 0, axis.y)
		direction.y = 0
		direction = direction.normalized() * axis.length()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
	if direction.length() > 0.05:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-direction.x, -direction.z), rotation_speed * delta)
	_update_target()

func _update_target() -> void:
	target = null
	GameFlow.prompt.text = ""
	if not controls_enabled or GameFlow.transitioning:
		return
	ray.force_raycast_update()
	if ray.is_colliding():
		var candidate := ray.get_collider() as Node3D
		if is_instance_valid(candidate) and candidate.has_method("interact") and global_position.distance_to(candidate.global_position) < 4.0:
			target = candidate
			GameFlow.prompt.text = candidate.get_prompt()
