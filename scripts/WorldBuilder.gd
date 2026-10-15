class_name WorldBuilder
extends Node3D
## Self-contained prototype scenery. Replace these meshes with licensed GLBs.
@export_enum("Island", "Forest", "Cinema") var act: int = 0
@export var cinema_video: VideoStream
@export_multiline var final_message: String = "Algumas viagens nos levam de volta ao que sentimos.\nObrigado por chegar até aqui."
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 42
	_setup_environment()
	match act:
		0: _island()
		1: _forest()
		2: _cinema()
	var player := preload("res://scenes/Player.tscn").instantiate() as PlayerController
	player.position = Vector3(0, 0.2, 7 if act != 2 else 9)
	add_child(player)

static func material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.8
	if glow:
		result.emission_enabled = true
		result.emission = color
		result.emission_energy_multiplier = 2.0
	return result

func box(pos: Vector3, size: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = material(color)
	visual.position = pos
	add_child(visual)
	if solid:
		var body := StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		visual.add_child(body)
	return visual

func _setup_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("90cbd5") if act == 0 else Color("101f24")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("ffe1b5") if act == 0 else Color("648b92")
	environment.ambient_light_energy = 0.65 if act == 0 else 0.25
	if act == 2:
		environment.ambient_light_energy = 0.02
	world.environment = environment
	add_child(world)
	if act != 2:
		var sun := DirectionalLight3D.new()
		sun.rotation_degrees = Vector3(-40, -35, 0)
		sun.light_color = Color("ffe0a3")
		sun.light_energy = 1.4 if act == 0 else 0.65
		sun.shadow_enabled = true
		add_child(sun)

func _boundaries(size: float) -> void:
	for side in [-1.0, 1.0]:
		for axis in [0, 1]:
			var body := StaticBody3D.new()
			body.position = Vector3(side * size, 2, 0) if axis == 0 else Vector3(0, 2, side * size)
			var collision := CollisionShape3D.new()
			var shape := BoxShape3D.new()
			shape.size = Vector3(1, 5, size * 2) if axis == 0 else Vector3(size * 2, 5, 1)
			collision.shape = shape
			body.add_child(collision)
			add_child(body)

func _door(pos: Vector3, forest: bool = false) -> void:
	var door := preload("res://scenes/DoorPortal.tscn").instantiate() as InteractiveDoor
	door.position = pos
	door.requires_key = forest
	if forest:
		door.target_scene = "res://scenes/Act3_Cinema.tscn"
	add_child(door)

func _tree(pos: Vector3, palm: bool) -> void:
	box(pos + Vector3(0, 2, 0), Vector3(0.45, 4, 0.45), Color("68513b"), true)
	if palm:
		for angle in range(6):
			var leaf := box(pos + Vector3(0, 4, 0), Vector3(0.65, 0.15, 4.5), Color("438258"))
			leaf.rotation = Vector3(0.25, angle * PI / 3.0, 0)
	else:
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.0
		mesh.bottom_radius = 1.9
		mesh.height = 4.7
		var leaves := MeshInstance3D.new()
		leaves.mesh = mesh
		leaves.position = pos + Vector3(0, 4, 0)
		leaves.material_override = material(Color("234c40"))
		add_child(leaves)

func _island() -> void:
	GameFlow.title.text = "ATO I  /  A ilha inicial"
	GameFlow.notify("Há uma porta entre a areia e o horizonte. Aproxime-se e olhe para ela.")
	box(Vector3(0, -0.3, 0), Vector3(27, 0.6, 27), Color("e1cb91"), true)
	var water := box(Vector3(0, -0.4, 0), Vector3(180, 0.1, 180), Color("369eae"))
	var shader := Shader.new()
	shader.code = "shader_type spatial; uniform vec4 water_color : source_color = vec4(0.08, 0.52, 0.63, 1.0); void vertex(){ VERTEX.y += sin(VERTEX.x * 0.65 + TIME) * 0.08 + cos(VERTEX.z * 0.55 + TIME * 0.8) * 0.06; } void fragment(){ ALBEDO = water_color.rgb; ROUGHNESS = 0.22; METALLIC = 0.25; }"
	var water_material := ShaderMaterial.new()
	water_material.shader = shader
	var plane := PlaneMesh.new()
	plane.size = Vector2(180, 180)
	plane.subdivide_width = 100
	plane.subdivide_depth = 100
	water.mesh = plane
	water.material_override = water_material
	for pos in [Vector3(-7, 0, -5), Vector3(8, 0, -7), Vector3(-9, 0, 5), Vector3(7, 0, 6)]:
		_tree(pos, true)
	_boundaries(12.5)
	_door(Vector3(0, 0, -3))

static func make_collectible(key: bool = false) -> CollectiblePiece:
	var piece := CollectiblePiece.new()
	piece.is_key = key
	# A short synthesized pickup chime keeps the prototype asset-free.
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = 22050
	var samples := PackedByteArray()
	for index in range(6615):
		var time := float(index) / 22050.0
		var amplitude := sin(TAU * (880.0 if key else 660.0) * time)
		var sample := int(amplitude * (1.0 - float(index) / 6615.0) * 10000.0)
		samples.append(sample & 255)
		samples.append((sample >> 8) & 255)
	sound.data = samples
	piece.pickup_sound = sound
	piece.collision_layer = 2
	piece.collision_mask = 0
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.7
	collision.shape = shape
	piece.add_child(collision)
	var visual := MeshInstance3D.new()
	var mesh := PrismMesh.new()
	mesh.size = Vector3(0.6, 0.85, 0.25) if not key else Vector3(0.3, 1.0, 0.2)
	visual.mesh = mesh
	visual.material_override = material(Color("ffd16c") if key else Color("73e7e0"), true)
	piece.add_child(visual)
	var light := OmniLight3D.new()
	light.light_color = Color("ffcd60") if key else Color("63dddc")
	light.omni_range = 3
	piece.add_child(light)
	return piece

func _forest() -> void:
	GameFlow.title.text = "ATO II  /  A floresta misteriosa"
	GameFlow.notify("Encontre três fragmentos luminosos. Depois, procure a chave no pedestal.")
	box(Vector3(0, -0.3, 0), Vector3(38, 0.6, 38), Color("293e32"), true)
	box(Vector3(0, 0.01, 0), Vector3(3, 0.02, 30), Color("59604a"))
	for index in range(60):
		var pos := Vector3(rng.randf_range(-17, 17), 0, rng.randf_range(-17, 17))
		if absf(pos.x) > 4:
			_tree(pos, false)
	_boundaries(18)
	_door(Vector3(0, 0, -10), true)
	var manager := ForestPuzzleManager.new()
	var marker := Marker3D.new()
	marker.position = Vector3(0, 1.6, -3)
	add_child(marker)
	manager.key_marker = marker
	add_child(manager)
	box(Vector3(0, 0.4, -3), Vector3(1.6, 0.8, 1.6), Color("72776a"), true)
	for pos in [Vector3(-3, 1.4, 3), Vector3(3, 1.4, -2), Vector3(-3, 1.4, -7)]:
		var piece := make_collectible()
		piece.position = pos
		manager.add_child(piece)
		manager.register(piece)

func _cinema() -> void:
	GameFlow.title.text = "ATO III  /  A última sessão"
	GameFlow.notify("Seu lugar está reservado. Procure a poltrona iluminada no corredor central.")
	box(Vector3(0, -0.25, 0), Vector3(24, 0.5, 28), Color("282332"), true)
	box(Vector3(-12, 4, 0), Vector3(0.4, 8, 28), Color("381c2b"), true)
	box(Vector3(12, 4, 0), Vector3(0.4, 8, 28), Color("381c2b"), true)
	box(Vector3(0, 4, -14), Vector3(24, 8, 0.4), Color("181723"), true)
	box(Vector3(0, 4, 14), Vector3(24, 8, 0.4), Color("381c2b"), true)
	box(Vector3(0, 8, 0), Vector3(24, 0.4, 28), Color("181723"), true)
	var screen := CinemaScreen.new()
	screen.position = Vector3(0, 4.2, -13.5)
	screen.video = cinema_video
	screen.final_message = final_message
	add_child(screen)
	var lights: Array[Light3D] = []
	for z in [-8, -1, 7]:
		for x in [-9, 9]:
			var light := OmniLight3D.new()
			light.position = Vector3(x, 3, z)
			light.light_color = Color("ffb26d")
			light.light_energy = 2
			light.omni_range = 10
			add_child(light)
			lights.append(light)
	for row in range(4):
		for column in [-7, -5, -3, 3, 5, 7]:
			_chair(Vector3(column, 0, -3 + row * 3))
	_chair(Vector3(0, 0, 2), true)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 2.3, 3.5)
	add_child(camera)
	camera.look_at(screen.global_position)
	var seat := CinemaSeat.new()
	seat.position = Vector3(0, 1, 2)
	seat.screen = screen
	seat.viewing_camera = camera
	seat.room_lights = lights
	seat.collision_layer = 2
	seat.collision_mask = 0
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.5, 2, 1.5)
	collision.shape = shape
	seat.add_child(collision)
	add_child(seat)
	var glow := OmniLight3D.new()
	glow.position = Vector3(0, 2.5, 2)
	glow.light_color = Color("ffe4a3")
	glow.omni_range = 4
	add_child(glow)
	seat.room_lights.append(glow)

func _chair(pos: Vector3, special: bool = false) -> void:
	var color := Color("bc824e") if special else Color("8f3046")
	box(pos + Vector3(0, 0.55, 0), Vector3(1.2, 0.3, 1.2), color, true)
	box(pos + Vector3(0, 1.1, 0.5), Vector3(1.2, 1.2, 0.25), color, true)
