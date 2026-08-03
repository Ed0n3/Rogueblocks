extends Node

const CATALOG_PATH: String = "res://content/content_catalog.tres"

var catalog: ContentCatalog
var pieces: Array[PieceDefinition] = []
var card_effects: Array[PieceCardEffectDefinition] = []
var enemies: Array[EnemyDefinition] = []
var relics: Array[RelicDefinition] = []
var upgrades: Array[UpgradeDefinition] = []
var events: Array[RunEventDefinition] = []
var difficulties: Array[DifficultyDefinition] = []
var statuses: Array[StatusDefinition] = []
var items: Array[ItemDefinition] = []
var counters: Array[CounterDefinition] = []
var artifacts: Array[BossArtifactDefinition] = []
var piece_modifiers: Array[PieceModifierDefinition] = []
var tutorials: Array[TutorialDefinition] = []

func _ready() -> void:
	reload_content()

func reload_content() -> void:
	catalog = ResourceLoader.load(CATALOG_PATH) as ContentCatalog
	if catalog == null:
		push_error("Content catalog could not be loaded")
		return
	pieces = catalog.pieces
	card_effects = catalog.card_effects
	enemies = catalog.enemies
	relics = catalog.relics
	upgrades = catalog.upgrades
	events = catalog.events
	difficulties = catalog.difficulties
	statuses = catalog.statuses
	items = catalog.items
	counters = catalog.counters
	artifacts = catalog.artifacts
	piece_modifiers = catalog.piece_modifiers
	tutorials = catalog.tutorials

func get_available_pieces(profile: ProfileState = null) -> Array[PieceDefinition]:
	var available: Array[PieceDefinition] = []
	for piece: PieceDefinition in pieces:
		if piece.initially_unlocked or (profile != null and profile.unlocked_pieces.has(piece)):
			available.append(piece)
	return available

func get_reward_pool(run_state: RunState) -> Array[RelicDefinition]:
	var pool: Array[RelicDefinition] = []
	var elite_defeated: bool = _current_node_is_elite(run_state)
	for relic: RelicDefinition in relics:
		var unlocked: bool = relic.initially_unlocked or run_state.starting_modifiers.unlocked_relics.has(relic)
		var artifact_requirements_met: bool = _artifact_requirements_met(relic, run_state)
		if unlocked and artifact_requirements_met and (not relic.elite_defeat_reward_only or elite_defeated) and (relic.consumable or relic.repeatable or not run_state.relics.has(relic)):
			pool.append(relic)
	return pool

func _artifact_requirements_met(relic: RelicDefinition, run_state: RunState) -> bool:
	for artifact: BossArtifactDefinition in relic.required_artifacts:
		if run_state.get_artifact_state(artifact) == null:
			return false
	return true

func _current_node_is_elite(run_state: RunState) -> bool:
	if run_state == null or run_state.route == null:
		return false
	var node: RouteNodeState = run_state.route.current_node
	return node != null and (node.type == RouteNodeState.NodeType.ELITE_COMBAT or node.type == RouteNodeState.NodeType.CHALLENGE)
