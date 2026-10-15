extends CanvasLayer
## Persistent HUD and serialized, failure-safe scene transitions.
var pieces: int = 0
var has_key: bool = false
var transitioning: bool = false
var prompt: Label
var status: Label
var title: Label
var fade: ColorRect
var toast_version: int = 0

func _ready() -> void:
	layer = 100
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	title = _label(ui, Vector2(36, 28), 26)
	status = _label(ui, Vector2(36, 72), 18)
	prompt = _label(ui, Vector2(36, 620), 22)
	var help := _label(ui, Vector2(36, 670), 16)
	help.text = "WASD / setas: mover   •   Mouse: câmera   •   E / Enter / Espaço: interagir   •   Esc: liberar mouse"
	fade = ColorRect.new()
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.color = Color(0, 0, 0, 0)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(fade)

func _label(parent: Control, pos: Vector2, size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func notify(message: String) -> void:
	toast_version += 1
	var version := toast_version
	status.text = message
	await get_tree().create_timer(4.0).timeout
	if version == toast_version:
		status.text = ""

func transition(path: String) -> void:
	if transitioning:
		return
	transitioning = true
	prompt.text = ""
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.65)
	await tween.finished
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		notify("Não foi possível abrir o cenário: " + path)
	await get_tree().process_frame
	tween = create_tween()
	tween.tween_property(fade, "color:a", 0.0, 0.65)
	await tween.finished
	transitioning = false
