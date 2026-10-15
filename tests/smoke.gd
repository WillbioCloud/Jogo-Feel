extends SceneTree
## Run after --editor --import so global script classes are registered.
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func load_act(path: String) -> Node:
	if current_scene:
		current_scene.queue_free()
		await process_frame
	var scene := load(path).instantiate() as Node
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	return scene

func _run() -> void:
	var island := await load_act("res://scenes/Act1_Island.tscn")
	check(island.get_node_or_null("Player") != null, "Island player missing")
	var island_doors: int = 0
	for child in island.get_children():
		if child is InteractiveDoor:
			island_doors += 1
	check(island_doors == 1, "Island door missing")
	var forest := await load_act("res://scenes/Act2_Forest.tscn")
	var manager: ForestPuzzleManager
	var door: InteractiveDoor
	var player := forest.get_node("Player") as PlayerController
	for child in forest.get_children():
		if child is ForestPuzzleManager:
			manager = child
		if child is InteractiveDoor:
			door = child
	check(manager != null and door != null, "Forest puzzle missing")
	var flow := root.get_node("GameFlow")
	door.interact(player)
	check(not door.busy and not flow.has_key, "Locked door accepted interaction")
	for piece in manager.get_children():
		if piece is CollectiblePiece:
			piece.interact(player)
			piece.interact(player)
	check(flow.pieces == 3, "Repeated collection changed the total")
	await process_frame
	var keys: int = 0
	for piece in manager.get_children():
		if piece is CollectiblePiece and piece.is_key:
			keys += 1
			piece.interact(player)
	check(keys == 1 and flow.has_key, "Golden key not revealed or collected")
	check(door.get_prompt() == "[E] Abrir a porta", "Door did not unlock")
	var cinema := await load_act("res://scenes/Act3_Cinema.tscn")
	var seat: CinemaSeat
	for child in cinema.get_children():
		if child is CinemaSeat:
			seat = child
	check(seat != null, "Cinema seat missing")
	player = cinema.get_node("Player") as PlayerController
	seat.interact(player)
	check(not player.controls_enabled and seat.occupied, "Seat did not lock controls")
	await create_timer(10.5).timeout
	check(seat.screen.started, "Cinema sequence did not start")
	check(seat.screen.ending.text == seat.screen.final_message, "Ending not displayed")
	print("Smoke tests complete; failures: ", failures)
	quit(0 if failures == 0 else 1)
