class_name ForestPuzzleManager
extends Node3D
@export var required_pieces: int = 3
@export var key_marker: Marker3D
var key_revealed: bool = false

func _ready() -> void:
	GameFlow.pieces = 0
	GameFlow.has_key = false

func register(piece: CollectiblePiece) -> void:
	piece.collected.connect(_on_collected)

func _on_collected(is_key: bool) -> void:
	if is_key:
		GameFlow.has_key = true
		GameFlow.notify("Chave dourada encontrada! A porta está destrancada.")
		return
	GameFlow.pieces += 1
	GameFlow.notify("Pedaço do portal encontrado! %d/%d" % [GameFlow.pieces, required_pieces])
	if GameFlow.pieces >= required_pieces and not key_revealed:
		key_revealed = true
		var key := WorldBuilder.make_collectible(true)
		add_child(key)
		key.global_position = key_marker.global_position
		key.base_height = key.position.y
		register(key)
		GameFlow.notify("Portal reconstruído! Uma chave dourada surgiu no pedestal central.")
