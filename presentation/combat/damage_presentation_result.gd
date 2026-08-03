class_name DamagePresentationResult
extends RefCounted

@export_category("Damage Thresholds")
@export_range(0.0, 1.0) var critical_damage_ratio: float = 0.35
@export_range(0.0, 1.0) var high_intensity_ratio: float = 0.35
@export_range(0.0, 1.0) var medium_intensity_ratio: float = 0.2
@export_range(0.0, 1.0) var low_intensity_ratio: float = 0.08
@export var high_intensity_level: int = 3
@export var medium_intensity_level: int = 2
@export var low_intensity_level: int = 1
@export var minimum_enemy_health: int = 1

var total_damage: int = 0
var health_damage: int = 0
var shield_damage: int = 0
var base_damage: int = 0
var bonus_damage: int = 0
var damage_over_time: int = 0
var sources: Array[PieceModifierDefinition] = []
var source_breakdown: Array[DamageSourcePresentation] = []
var is_cross_clear: bool = false
var is_perfect_clear: bool = false
var is_critical: bool = false
var killed_enemy: bool = false
var enemy_maximum_health: int = 1

static func from_damage_result(damage: DamageResult) -> DamagePresentationResult:
	var result: DamagePresentationResult = DamagePresentationResult.new()
	result.total_damage = damage.health_damage + damage.shield_damage
	if result.total_damage <= 0:
		result.total_damage = damage.final_damage
	result.health_damage = damage.health_damage
	result.shield_damage = damage.shield_damage
	result.base_damage = damage.base_damage
	result.bonus_damage = damage.bonus_damage + damage.modifier_bonus
	result.sources = damage.sources.duplicate()
	result.is_cross_clear = damage.cross_clear
	result.is_perfect_clear = damage.perfect_clear
	result.killed_enemy = damage.killed_enemy
	result.enemy_maximum_health = maxi(result.minimum_enemy_health, damage.enemy_maximum_health)
	result.is_critical = result.is_perfect_clear or float(result.total_damage) / float(result.enemy_maximum_health) >= result.critical_damage_ratio
	for modifier: PieceModifierDefinition in result.sources:
		var source: DamageSourcePresentation = DamageSourcePresentation.new()
		source.source = modifier
		source.display_name = modifier.display_name
		source.accent_color = modifier.visual_definition.accent_color if modifier != null and modifier.visual_definition != null else Color.WHITE
		result.source_breakdown.append(source)
	return result

func intensity() -> int:
	var ratio: float = float(total_damage) / float(maxi(minimum_enemy_health, enemy_maximum_health))
	if ratio >= high_intensity_ratio:
		return high_intensity_level
	if ratio >= medium_intensity_ratio:
		return medium_intensity_level
	if ratio >= low_intensity_ratio:
		return low_intensity_level
	return 0
