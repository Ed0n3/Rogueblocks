class_name DebugEncounterConfiguration
extends RefCounted

var enemy: EnemyDefinition
var difficulty: DifficultyDefinition
var seed_value: int = 0
var player_health: int = 0
var player_shield: int = -1
var board_width: int = 0
var board_height: int = 0
var pieces: Array[DebugEncounterPieceSelection] = []
var items: Array[DebugEncounterItemSelection] = []
var relics: Array[RelicDefinition] = []
var artifacts: Array[BossArtifactDefinition] = []

func duplicate_configuration() -> DebugEncounterConfiguration:
	var copy: DebugEncounterConfiguration = DebugEncounterConfiguration.new()
	copy.enemy = enemy
	copy.difficulty = difficulty
	copy.seed_value = seed_value
	copy.player_health = player_health
	copy.player_shield = player_shield
	copy.board_width = board_width
	copy.board_height = board_height
	for selection: DebugEncounterPieceSelection in pieces:
		copy.pieces.append(selection.duplicate_selection() if selection != null else null)
	for selection: DebugEncounterItemSelection in items:
		copy.items.append(selection.duplicate_selection() if selection != null else null)
	copy.relics.assign(relics)
	copy.artifacts.assign(artifacts)
	return copy

func get_item_selection(item: ItemDefinition) -> DebugEncounterItemSelection:
	for selection: DebugEncounterItemSelection in items:
		if selection != null and selection.item == item:
			return selection
	return null

func remove_item(item: ItemDefinition) -> void:
	var selection: DebugEncounterItemSelection = get_item_selection(item)
	if selection != null:
		items.erase(selection)
