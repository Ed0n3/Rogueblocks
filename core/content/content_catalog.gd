class_name ContentCatalog
extends Resource

@export var pieces: Array[PieceDefinition] = []
@export var card_effects: Array[PieceCardEffectDefinition] = []
@export var enemies: Array[EnemyDefinition] = []
@export var relics: Array[RelicDefinition] = []
@export var upgrades: Array[UpgradeDefinition] = []
@export var events: Array[RunEventDefinition] = []
@export var difficulties: Array[DifficultyDefinition] = []
@export var statuses: Array[StatusDefinition] = []
@export var items: Array[ItemDefinition] = []
@export var counters: Array[CounterDefinition] = []
@export var artifacts: Array[BossArtifactDefinition] = []
@export var piece_modifiers: Array[PieceModifierDefinition] = []
@export var tutorials: Array[TutorialDefinition] = []
@export var legacy_aliases: Array[LegacyContentAlias] = []

func all_definitions() -> Array[Resource]:
	var definitions: Array[Resource] = []
	definitions.append_array(pieces)
	definitions.append_array(card_effects)
	definitions.append_array(enemies)
	definitions.append_array(relics)
	definitions.append_array(upgrades)
	definitions.append_array(events)
	definitions.append_array(difficulties)
	definitions.append_array(statuses)
	definitions.append_array(items)
	definitions.append_array(counters)
	definitions.append_array(artifacts)
	definitions.append_array(piece_modifiers)
	definitions.append_array(tutorials)
	return definitions

func resolve_legacy(legacy_id: StringName, expected_type: Variant) -> Resource:
	for alias: LegacyContentAlias in legacy_aliases:
		if alias.legacy_id == legacy_id and is_instance_of(alias.definition, expected_type):
			return alias.definition
	return null
