extends Control

const EMBER_MODIFIER: PieceModifierDefinition = preload("res://content/piece_modifiers/ember_brand.tres")
const EMBER_RELIC: RelicDefinition = preload("res://content/relics/ember_brand.tres")
const FRACTURE_MODIFIER: PieceModifierDefinition = preload("res://content/piece_modifiers/fracture_rune.tres")
const FRACTURE_RELIC: RelicDefinition = preload("res://content/relics/fracture_rune.tres")
const STRAIGHT_PIECE: PieceDefinition = preload("res://content/pieces/tet_i.tres")
const SQUARE_PIECE: PieceDefinition = preload("res://content/pieces/tet_o.tres")

func _ready() -> void:
	var run: RunState = RunState.new()
	var ember: PieceModifierState = PieceModifierState.new()
	ember.definition = EMBER_MODIFIER
	ember.source_relic = EMBER_RELIC
	ember.target_pieces = [STRAIGHT_PIECE]
	run.add_piece_modifier(ember)
	var fracture: PieceModifierState = PieceModifierState.new()
	fracture.definition = FRACTURE_MODIFIER
	fracture.source_relic = FRACTURE_RELIC
	fracture.target_pieces = [SQUARE_PIECE]
	run.add_piece_modifier(fracture)
	var board: BoardState = BoardState.new(8, 8)
	var straight: PieceDefinition = STRAIGHT_PIECE
	var square: PieceDefinition = SQUARE_PIECE
	var straight_instance: PieceInstance = PieceInstance.new(straight)
	straight_instance.modifiers = [EMBER_MODIFIER]
	board.place_piece(Vector2i(1, 6), straight_instance)
	var square_instance: PieceInstance = PieceInstance.new(square)
	square_instance.modifiers = [FRACTURE_MODIFIER]
	board.place_piece(Vector2i(5, 5), square_instance)
	var architect_hand_effect: ArchitectHandEffect = ArchitectHandEffect.new()
	var ignited_monoblock: PieceInstance = PieceInstance.new(architect_hand_effect.generated_piece)
	ignited_monoblock.source_type = PieceSourceType.Value.ARTIFACT_GENERATED
	ignited_monoblock.modifiers = [architect_hand_effect.fire_visual_modifier]
	board.place_piece(Vector2i(6, 0), ignited_monoblock)
	board.set_special_cell(Vector2i(7, 0), CellType.Value.BLOCKER, 1)
	%BoardView.set_board(board)
	%BoardView.set_active_piece(straight_instance.duplicate_instance())
	%BoardView.preview_origin = Vector2i(2, 3)
	%BoardView.preview_visible = true
	%StraightChoice.set_piece(straight, true, true, false)
	%StraightChoice.set_modifiers(run.get_piece_modifiers(straight))
	%SquareChoice.set_piece(square, false, true, false)
	%SquareChoice.set_modifiers(run.get_piece_modifiers(square))
	for entry: PiecePoolEntry in run.get_current_piece_pool():
		if entry.piece == straight:
			%PoolCard.setup(entry)
			break
	var screenshot_path: String = _screenshot_path()
	if not screenshot_path.is_empty():
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var screenshot: Image = get_viewport().get_texture().get_image()
		if screenshot != null:
			screenshot.save_png(screenshot_path)
		get_tree().quit()

func _screenshot_path() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--screenshot="):
			return argument.trim_prefix("--screenshot=")
	return ""
