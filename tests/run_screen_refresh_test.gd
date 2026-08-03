extends Node

const VAULT_SHAPES_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/vault_shapes.tres")
const MONOMINO_PIECE: PieceDefinition = preload("res://content/pieces/monomino.tres")
const TRAINING_SLIME_ENEMY: EnemyDefinition = preload("res://content/enemies/training_slime.tres")

var checks: TestAssertions = TestAssertions.new()

func _ready() -> void:
	await get_tree().process_frame
	var combo_shader: Shader = load("res://presentation/shaders/combo_text.gdshader") as Shader
	checks.truthy(combo_shader != null, "Combo text shader loads")
	var legacy_state: BossArtifactState = BossArtifactState.from_save_data({"artifact_id": "vault_shapes", "stored_piece_id": "mono"})
	checks.truthy(legacy_state.stored_cards.size() == 1 and legacy_state.stored_cards[0].piece == MONOMINO_PIECE, "Legacy Vault state migrates to piece-card storage")
	checks.equal(VaultStorageService.new().capacity(), 1, "Vault list starts at one slot")
	var run_state: RunState = RunState.new()
	run_state.add_artifact(VAULT_SHAPES_ARTIFACT, 0)
	var vault_state: BossArtifactState = run_state.get_artifact_state(VAULT_SHAPES_ARTIFACT)
	var stored_card: PieceCardState = PieceCardState.new()
	stored_card.piece = ContentRegistry.pieces[0]
	vault_state.stored_cards = [stored_card]
	var screen: RunScreen = (load("res://scenes/run/run_screen.tscn") as PackedScene).instantiate() as RunScreen
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(1280, 720)
	var previous_tutorials_enabled: bool = SaveService.profile.tutorial_progress.tutorials_enabled
	SaveService.profile.tutorial_progress.tutorials_enabled = false
	checks.truthy(screen.start(run_state, TRAINING_SLIME_ENEMY, PieceGenerator.new(7113)), "Run screen starts")
	await get_tree().process_frame
	await get_tree().process_frame
	checks.falsy(screen.has_node("MainMargin/ScreenLayout/TopStatus/StatusRow/ScoreBlock"), "Score is internal only")
	checks.falsy(screen.has_node("MainMargin/ScreenLayout/TopStatus/StatusRow/PlayerPanel/PlayerHealthTrail"), "Player trail bar is removed")
	checks.falsy(screen.has_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/EnemyStage/EnemyLayout/EnemyHealthTrail"), "Enemy trail bar is removed")
	checks.falsy(screen.has_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/EnemyStage/EnemyLayout/IntentRow/NextActionLabel"), "Next label is removed")
	checks.falsy(screen.has_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/ChoiceTitle"), "Shape selection label is removed")
	var player_statuses: StatusStripView = screen.get_node("MainMargin/ScreenLayout/TopStatus/StatusRow/PlayerPanel/PlayerHealthRow/PlayerStatuses") as StatusStripView
	checks.equal(player_statuses.custom_minimum_size.x, 150.0, "Player statuses reserve stable width")
	var enemy_health_bar: StatusHealthBar = screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/EnemyStage/EnemyLayout/EnemyVisualArea/EnemyHealthRow/VBoxContainer/EnemyHealthBar") as StatusHealthBar
	checks.truthy(enemy_health_bar.custom_minimum_size.x <= 80.0, "Enemy health bar is one third width")
	var enemy_visual_area: Control = screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/EnemyStage/EnemyLayout/EnemyVisualArea") as Control
	checks.truthy(enemy_visual_area.custom_minimum_size.y >= 124.0, "Enemy visual area gives sprites more space")
	var draft_panel: PanelContainer = screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel") as PanelContainer
	checks.truthy(draft_panel.get_global_rect().end.y <= screen.size.y - 8.0, "Recomposed combat column fits at 720p")
	var vault_list: Control = screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/VaultPieceList") as Control
	var displayed_vault_state: BossArtifactState = vault_list.get("artifact_state") as BossArtifactState
	checks.truthy(vault_list.visible and displayed_vault_state.stored_cards.size() == 1, "Vault list displays stored Blocks")
	var combo: Label = screen.get_node("MainMargin/ScreenLayout/TopStatus/StatusRow/Combo") as Label
	var combo_position: Vector2 = combo.position
	var burn: StatusDefinition = preload("res://content/statuses/burn.tres") as StatusDefinition
	run_state.player_statuses.apply_status(burn, burn, 3, 2)
	screen._update_status()
	await get_tree().process_frame
	var player_health_bar: StatusHealthBar = screen.get_node("MainMargin/ScreenLayout/TopStatus/StatusRow/PlayerPanel/PlayerHealthRow/PlayerHealthRow2/PlayerHealthBar") as StatusHealthBar
	checks.truthy(player_health_bar.get_effect_strength(StatusVisualChannel.Value.BURN) > 0.0, "Player Burn activates the health-bar shader")
	checks.equal(combo.position, combo_position, "Status changes do not shift the upper bar")
	checks.truthy(player_statuses.has_visible_effects(), "Larger status view displays effects")
	player_statuses.call("_show_details", 0)
	checks.truthy((screen.get_node("StatusEffectInfoOverlay") as Control).visible, "Touch hold details use the status window")
	screen._apply_mobile_layout(true)
	checks.truthy((screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/RotateLeft") as Button).visible, "Mobile keeps left rotation available")
	checks.truthy((screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/RotateRight") as Button).visible, "Mobile keeps right rotation available")
	checks.truthy((screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/PlaceButton") as Button).custom_minimum_size.y >= screen.mobile_place_minimum_height, "Mobile enlarges Place")
	var screenshot_path: String = _screenshot_path()
	if not screenshot_path.is_empty():
		(screen.get_node("StatusEffectInfoOverlay") as Control).hide()
		screen._apply_mobile_layout(false)
		screen.presentation.motion.animation_speed = 2.0
		var damage: DamageResult = DamageResult.new()
		damage.final_damage = 7
		damage.health_damage = 7
		damage.enemy_maximum_health = 12
		screen.presentation.enqueue_enemy_damage(damage)
		await get_tree().create_timer(0.2).timeout
		checks.truthy(screen.vfx.rings.any(func(ring: ImpactRing) -> bool: return ring.visible), "Run screen shows the enemy damage impact")
		checks.truthy(screen.vfx.texts.any(func(floating: FloatingText) -> bool: return floating.visible and floating.text == "-7"), "Run screen shows its floating damage number")
		await RenderingServer.frame_post_draw
		var screenshot: Image = screen.get_viewport().get_texture().get_image()
		if screenshot != null:
			screenshot.save_png(screenshot_path)
		await screen.presentation.wait_until_idle()
	SaveService.profile.tutorial_progress.tutorials_enabled = previous_tutorials_enabled
	print("Run screen refresh tests: %d passed, %d failed" % [checks.passed, checks.failed])
	get_tree().quit(checks.failed)

func _screenshot_path() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--screenshot="):
			return argument.trim_prefix("--screenshot=")
	return ""
