class_name EffectResult
extends RefCounted

var applied: bool = false
var health_damage: int = 0
var shield_damage: int = 0
var healing: int = 0
var shield_granted: int = 0
var countdown_change: int = 0
var affected_cells: Array[Vector2i] = []
var applied_statuses: Array[StatusDefinition] = []
var removed_statuses: Array[StatusDefinition] = []
var messages: Array[String] = []
var damage_results: Array[DamageResult] = []
var moved_cards: Array[PieceCardState] = []

func merge(other: EffectResult) -> void:
	applied = applied or other.applied
	health_damage += other.health_damage
	shield_damage += other.shield_damage
	healing += other.healing
	shield_granted += other.shield_granted
	countdown_change += other.countdown_change
	affected_cells.append_array(other.affected_cells)
	applied_statuses.append_array(other.applied_statuses)
	removed_statuses.append_array(other.removed_statuses)
	messages.append_array(other.messages)
	damage_results.append_array(other.damage_results)
	moved_cards.append_array(other.moved_cards)
