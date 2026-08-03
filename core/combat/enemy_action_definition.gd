class_name EnemyActionDefinition
extends Resource

@export var display_name: String
@export_multiline var intent_description: String
@export var action_tags: Array[StringName] = []
@export var consumes_empowered_venom: bool = false
@export var schedules_cursed_draft: bool = false
@export var effects: Array[GameplayEffect] = []
@export var counter_definition: CounterDefinition
@export var minimum_phase: int = 0
@export var weight: float = 1.0
@export var cooldown_actions: int = 0
@export var cannot_repeat: bool = false
@export var applied_statuses: Array[StatusDefinition] = []
@export var icon_type: EnemyIntentIcon.Value = EnemyIntentIcon.Value.DAMAGE
@export var accent_color: Color = Color("ff786f")
@export var minimum_health_percent: float = 0.0
@export var maximum_health_percent: float = 1.0
@export var requires_empty_cell: bool = false
@export var required_absent_block_flag: CellFlag.Value = CellFlag.Value.NONE
@export var disallow_while_shielded: bool = false
@export var disallow_status_refresh: bool = false
@export var shield_duration_placements: int = 0

@export var direct_damage: int = 0
@export var blocker_count: int = 0
@export var special_cell_type: CellType.Value = CellType.Value.EMPTY
@export var special_cell_count: int = 0
@export var special_cell_value: int = 0
@export var enemy_healing: int = 0

func execute(board: BoardState, rng: RandomNumberGenerator) -> EnemyActionResult:
	var result: EnemyActionResult = EnemyActionResult.new()
	result.player_damage = direct_damage
	result.enemy_healing = enemy_healing
	if blocker_count > 0:
		result.affected_cells.append_array(board.add_blockers(blocker_count, rng))
	if special_cell_count > 0:
		var candidates: Array[Vector2i] = []
		for y: int in board.height:
			for x: int in board.width:
				var cell: Vector2i = Vector2i(x, y)
				if board.is_empty(cell):
					candidates.append(cell)
		for index: int in mini(special_cell_count, candidates.size()):
			var selected: Vector2i = candidates.pop_at(rng.randi_range(0, candidates.size() - 1))
			board.set_special_cell(selected, special_cell_type, special_cell_value)
			result.affected_cells.append(selected)
	return result

func execute_with_context(board: BoardState, rng: RandomNumberGenerator, context: EffectContext) -> EnemyActionResult:
	var result: EnemyActionResult = execute(board, rng)
	if context == null or effects.is_empty():
		return result
	context.source = self
	var effect_result: EffectResult = EffectResolver.new().resolve(effects, context)
	result.affected_cells.append_array(effect_result.affected_cells)
	return result
