class_name ArchitectHandEffect
extends BossArtifactEffect

@export var generated_piece: PieceDefinition = preload("res://content/pieces/monomino.tres") as PieceDefinition
@export var fire_visual_modifier: PieceModifierDefinition = preload("res://content/piece_modifiers/archlord_fire_visual.tres") as PieceModifierDefinition
@export var placement_interval: int = 3
@export var fire_status: StatusDefinition
@export var fire_duration_turns: int = 3
@export var activation_message: String = "Archlord's Hand placed an ignited Monoblock"

func on_encounter_started(context: ArtifactEffectContext) -> void:
	context.artifact_state.trigger_counter = 0

func after_piece_placement(context: ArtifactEffectContext) -> void:
	if context.piece_source_type != PieceSourceType.Value.DRAWN_CARD:
		return
	context.artifact_state.trigger_counter += 1
	if context.artifact_state.trigger_counter < placement_interval:
		return
	context.artifact_state.trigger_counter = 0
	var empty_cells: Array[Vector2i] = []
	for y: int in context.board.height:
		for x: int in context.board.width:
			var cell: Vector2i = Vector2i(x, y)
			if context.board.is_empty(cell):
				empty_cells.append(cell)
	if empty_cells.is_empty():
		return
	var selected: Vector2i = empty_cells[context.rng.randi_range(0, empty_cells.size() - 1)]
	var monoblock: PieceInstance = PieceInstance.new(generated_piece)
	monoblock.source_type = PieceSourceType.Value.ARTIFACT_GENERATED
	monoblock.modifiers = [fire_visual_modifier]
	var placement: PlacementResult = context.board.place_piece(selected, monoblock)
	if not placement.success:
		return
	context.enemy_status = fire_status
	context.enemy_status_duration = fire_duration_turns
	context.activation_message = activation_message
	context.activated = true
