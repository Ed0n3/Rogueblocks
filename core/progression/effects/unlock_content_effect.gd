class_name UnlockContentEffect
extends PermanentUpgradeEffect

@export var pieces: Array[PieceDefinition] = []
@export var relics: Array[RelicDefinition] = []
@export var enemies: Array[EnemyDefinition] = []
@export var events: Array[RunEventDefinition] = []
@export var route_node_types: Array[RouteNodeState.NodeType] = []

func apply_to_starting_modifiers(modifiers: StartingRunModifiers, purchased_level: int, source: UpgradeDefinition = null) -> void:
	super.apply_to_starting_modifiers(modifiers, purchased_level, source)
	if purchased_level <= 0:
		return
	_append_unique(modifiers.unlocked_pieces, pieces)
	_append_unique(modifiers.unlocked_relics, relics)
	_append_unique(modifiers.unlocked_enemies, enemies)
	_append_unique(modifiers.unlocked_events, events)
	_append_unique(modifiers.unlocked_route_node_types, route_node_types)

func apply_to_profile(profile: ProfileState) -> void:
	_append_unique(profile.unlocked_pieces, pieces)
	_append_unique(profile.unlocked_relics, relics)
	_append_unique(profile.unlocked_enemies, enemies)
	_append_unique(profile.unlocked_events, events)

func _append_unique(target: Array, source: Array) -> void:
	for definition: Resource in source:
		if not target.has(definition):
			target.append(definition)
