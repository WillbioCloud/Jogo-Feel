class_name InteractiveDoor
extends Area3D
@export_file("*.tscn") var target_scene: String = "res://scenes/Act2_Forest.tscn"
@export var requires_key: bool = false
var busy: bool = false

func get_prompt() -> String:
	if requires_key and not GameFlow.has_key:
		return "Porta selada — encontre os três fragmentos e a chave dourada"
	return "[E] Abrir a porta"

func interact(_player: PlayerController) -> void:
	if busy or GameFlow.transitioning:
		return
	if requires_key and not GameFlow.has_key:
		GameFlow.notify("A porta precisa da chave dourada.")
		return
	busy = true
	var tween := create_tween()
	tween.tween_property($Hinge, "rotation:y", -PI * 0.55, 0.7).set_trans(Tween.TRANS_SINE)
	await tween.finished
	await GameFlow.transition(target_scene)
	if is_inside_tree():
		busy = false
