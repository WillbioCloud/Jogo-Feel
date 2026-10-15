class_name CinemaScreen
extends Node3D
## A SubViewport projects native Theora video onto a physical screen.
@export var video: VideoStream
@export_multiline var final_message: String = "Algumas viagens nos levam de volta ao que sentimos.\nObrigado por chegar até aqui."
var viewport: SubViewport
var player: VideoStreamPlayer
var ending: Label
var started: bool = false

func _ready() -> void:
	viewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	add_child(viewport)
	var background := ColorRect.new()
	background.size = Vector2(1280, 720)
	background.color = Color(0.008, 0.012, 0.025)
	viewport.add_child(background)
	player = VideoStreamPlayer.new()
	player.size = Vector2(1280, 720)
	player.expand = true
	player.stream = video
	viewport.add_child(player)
	player.finished.connect(_finish)
	ending = Label.new()
	ending.position = Vector2(80, 240)
	ending.size = Vector2(1120, 240)
	ending.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ending.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ending.add_theme_font_size_override("font_size", 40)
	ending.modulate.a = 0.0
	viewport.add_child(ending)
	var screen := MeshInstance3D.new()
	var mesh := QuadMesh.new()
	mesh.size = Vector2(10, 5.625)
	screen.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = viewport.get_texture()
	screen.material_override = material
	add_child(screen)

func play() -> void:
	if started:
		return
	started = true
	if video:
		player.play()
	else:
		GameFlow.notify("Vídeo não configurado — exibindo sequência de demonstração.")
		ending.text = "FEEL\nUma viagem em três atos"
		var tween := create_tween()
		tween.tween_property(ending, "modulate:a", 1.0, 1.5)
		tween.tween_interval(3.0)
		tween.tween_property(ending, "modulate:a", 0.0, 1.0)
		await tween.finished
		_finish()

func _finish() -> void:
	ending.text = final_message
	create_tween().tween_property(ending, "modulate:a", 1.0, 2.0)
	GameFlow.notify("Fim da viagem. Obrigado por jogar.")
