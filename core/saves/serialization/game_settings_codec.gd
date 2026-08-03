class_name GameSettingsCodec
extends RefCounted

static func encode(settings: GameSettings) -> Dictionary:
	return {
		"master_volume": settings.master_volume,
		"music_volume": settings.music_volume,
		"effects_volume": settings.effects_volume,
		"fullscreen": settings.fullscreen,
		"screen_shake": settings.screen_shake,
		"reduced_motion": settings.reduced_motion,
		"flashes_enabled": settings.flashes_enabled,
		"particle_density": settings.particle_density,
		"combat_animation_speed": settings.combat_animation_speed,
		"larger_combat_text": settings.larger_combat_text,
		"tutorial_message_duration": settings.tutorial_message_duration,
		"tutorial_manual_advance": settings.tutorial_manual_advance,
		"tutorial_large_text": settings.tutorial_large_text,
		"tutorial_high_contrast": settings.tutorial_high_contrast,
		"last_used_seed": settings.last_used_seed
	}

static func decode(data: Dictionary) -> GameSettings:
	var settings: GameSettings = GameSettings.new()
	settings.master_volume = clampf(float(data.get("master_volume", settings.master_volume)), 0.0, 1.0)
	settings.music_volume = clampf(float(data.get("music_volume", settings.music_volume)), 0.0, 1.0)
	settings.effects_volume = clampf(float(data.get("effects_volume", settings.effects_volume)), 0.0, 1.0)
	settings.fullscreen = bool(data.get("fullscreen", settings.fullscreen))
	settings.screen_shake = bool(data.get("screen_shake", settings.screen_shake))
	settings.reduced_motion = bool(data.get("reduced_motion", settings.reduced_motion))
	settings.flashes_enabled = bool(data.get("flashes_enabled", settings.flashes_enabled))
	settings.particle_density = clampf(float(data.get("particle_density", settings.particle_density)), 0.0, 1.0)
	settings.combat_animation_speed = clampf(float(data.get("combat_animation_speed", settings.combat_animation_speed)), 0.0, 2.0)
	settings.larger_combat_text = bool(data.get("larger_combat_text", settings.larger_combat_text))
	settings.tutorial_message_duration = maxf(0.5, float(data.get("tutorial_message_duration", settings.tutorial_message_duration)))
	settings.tutorial_manual_advance = bool(data.get("tutorial_manual_advance", settings.tutorial_manual_advance))
	settings.tutorial_large_text = bool(data.get("tutorial_large_text", settings.tutorial_large_text))
	settings.tutorial_high_contrast = bool(data.get("tutorial_high_contrast", settings.tutorial_high_contrast))
	settings.last_used_seed = int(data.get("last_used_seed", settings.last_used_seed))
	return settings
