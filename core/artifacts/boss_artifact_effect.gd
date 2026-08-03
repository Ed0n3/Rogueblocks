class_name BossArtifactEffect
extends Resource

@export var priority: int = 0

func modify_draw_count(_context: ArtifactEffectContext) -> void:
	pass

func modify_placement_economy(_context: ArtifactEffectContext) -> void:
	pass

func before_piece_placement(_context: ArtifactEffectContext) -> void:
	pass

func after_piece_placement(_context: ArtifactEffectContext) -> void:
	pass

func after_line_clear(_context: ArtifactEffectContext) -> void:
	pass

func modify_enemy_countdown(_context: ArtifactEffectContext) -> void:
	pass

func on_encounter_started(_context: ArtifactEffectContext) -> void:
	pass

func on_item_phase(_context: ArtifactEffectContext) -> void:
	pass

func modify_combo_resolution(_context: ArtifactEffectContext) -> void:
	pass
