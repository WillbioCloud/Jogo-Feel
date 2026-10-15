class_name CollectiblePiece
extends Area3D
signal collected(is_key: bool)
@export var is_key: bool = false
@export var pickup_sound: AudioStream
var taken: bool = false
var elapsed: float = 0.0
var base_height: float

func _ready() -> void:
	base_height = position.y

func _process(delta: float) -> void:
	elapsed += delta
	position.y = base_height + sin(elapsed * 2.0) * 0.16
	rotation.y += delta

func get_prompt() -> String:
	return "[E] Pegar chave dourada" if is_key else "[E] Recolher fragmento do portal"

func interact(_player: PlayerController) -> void:
	if taken:
		return
	taken = true
	if pickup_sound:
		var audio := AudioStreamPlayer.new()
		get_tree().current_scene.add_child(audio)
		audio.stream = pickup_sound
		audio.finished.connect(audio.queue_free)
		audio.play()
	collected.emit(is_key)
	queue_free()
