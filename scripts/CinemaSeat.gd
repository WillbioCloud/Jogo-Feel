class_name CinemaSeat
extends Area3D
@export var screen: CinemaScreen
@export var viewing_camera: Camera3D
@export var room_lights: Array[Light3D] = []
var occupied: bool = false

func get_prompt() -> String:
	return "[E] Sentar e assistir"

func interact(player: PlayerController) -> void:
	if occupied:
		return
	occupied = true
	player.controls_enabled = false
	player.velocity = Vector3.ZERO
	GameFlow.prompt.text = ""
	var destination := viewing_camera.global_transform
	viewing_camera.global_transform = player.camera.global_transform
	viewing_camera.fov = player.camera.fov
	viewing_camera.make_current()
	var tween := create_tween().set_parallel(true)
	tween.tween_property(viewing_camera, "global_transform", destination, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for light in room_lights:
		tween.tween_property(light, "light_energy", 0.0, 2.5)
	await tween.finished
	screen.play()
