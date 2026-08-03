extends Control

const ARCHITECT_ENEMY: EnemyDefinition = preload("res://content/enemies/architect.tres")

func _ready() -> void:
	%EnemyPresentation.configure(ARCHITECT_ENEMY, ARCHITECT_ENEMY.visual)
	var motion: MotionSettings = MotionSettings.from_saved_settings(SaveService.settings)
	MotionPresets.pop_in(%ThemePanel, 0.04, motion)
	MotionPresets.pop_in(%EnemyPanel, 0.1, motion)
