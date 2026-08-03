class_name DebugEncounterSetupScreen
extends Control

signal encounter_requested(configuration: DebugEncounterConfiguration)
signal back_requested()

enum CatalogTab { BLOCKS, ITEMS, RELICS, ARTIFACTS }
enum PickerTarget { NONE, ENEMY, DIFFICULTY, PIECE, EFFECT, ITEM_PIECE }

@export_category("Content")
@export var rules: DebugEncounterRules = preload("res://content/rules/debug_encounter_rules.tres") as DebugEncounterRules
@export var game_rules: GameRules = preload("res://content/rules/default_game_rules.tres") as GameRules
@export var piece_row_scene: PackedScene = preload("res://scenes/debug/debug_piece_loadout_row.tscn") as PackedScene
@export var content_toggle_scene: PackedScene = preload("res://scenes/debug/debug_content_toggle.tscn") as PackedScene
@export var empty_icon: Texture2D = preload("res://assets/icons/empty_texture.tres") as Texture2D

@export_category("Layout")
@export var mobile_breakpoint_width: float = 760.0
@export var touch_scroll_direction_threshold: float = 12.0
@export_range(1, 64, 1) var minimum_board_dimension: int = 1
@export_range(1, 64, 1) var maximum_board_dimension: int = 32
@export_range(1, 999, 1) var maximum_player_health: int = 999
@export_range(0, 999, 1) var maximum_player_shield: int = 999
@export var maximum_seed_value: int = 2147483647

@export_category("Presentation")
@export var relic_accent_color: Color = Color("7ee7d8")
@export var artifact_drawback_label: String = "DRAWBACK"
@export var enemy_summary_format: String = "%s  |  HP %d  |  ACT %d-%d  |  MOVES EVERY %d"
@export var difficulty_summary_format: String = "ENEMY HP ×%.2f  |  INTERVAL %+d  |  BLOCKERS %d  |  DRAW %+d"
## Compact summary of the configured enemy, pile, items, relics, and artifacts.
@export var selection_summary_format: String = "%s  |  %d PIECES  |  %d EFFECTS  |  %d ITEMS  |  %d RELICS  |  %d ARTIFACTS"
## Label used by Block Capsule item rows for their stored piece.
@export var stored_piece_format: String = "STORED BLOCK: %s"
## Tooltip used by the stored-piece picker.
@export var stored_piece_details_format: String = "%s  |  %d CELLS"
@export var enemy_role_names: Array[String] = ["NORMAL", "ELITE", "BOSS"]

var configuration: DebugEncounterConfiguration
var enemies: Array[EnemyDefinition] = []
var difficulties: Array[DifficultyDefinition] = []
var pieces: Array[PieceDefinition] = []
var effects: Array[PieceCardEffectDefinition] = []
var items: Array[ItemDefinition] = []
var relics: Array[RelicDefinition] = []
var artifacts: Array[BossArtifactDefinition] = []
var piece_rows: Array[DebugPieceLoadoutRow] = []
var item_rows: Array[DebugContentToggle] = []
var relic_rows: Array[DebugContentToggle] = []
var artifact_rows: Array[DebugContentToggle] = []
var active_tab: CatalogTab = CatalogTab.BLOCKS
var picker_target: PickerTarget = PickerTarget.NONE
var picker_row: DebugPieceLoadoutRow
var picker_item: ItemDefinition
var scroll_touch_index: int = -1
var scroll_touch_start: Vector2
var scroll_touch_axis: Vector2i = Vector2i.ZERO
var configuring: bool = false
var desktop_back_minimum_size: Vector2
var desktop_reset_minimum_size: Vector2
var desktop_start_minimum_size: Vector2
var desktop_setup_field_minimum_sizes: Array[Vector2] = []

func _ready() -> void:
	desktop_back_minimum_size = %Back.custom_minimum_size
	desktop_reset_minimum_size = %Reset.custom_minimum_size
	desktop_start_minimum_size = %StartTest.custom_minimum_size
	for child: Node in %SetupGrid.get_children():
		var field: Control = child as Control
		if field != null:
			desktop_setup_field_minimum_sizes.append(field.custom_minimum_size)
	%Back.pressed.connect(func() -> void: back_requested.emit())
	%Reset.pressed.connect(_reset_configuration)
	%StartTest.pressed.connect(_request_encounter)
	%AddPiece.pressed.connect(_add_piece)
	%BlocksTab.pressed.connect(_show_tab.bind(CatalogTab.BLOCKS))
	%ItemsTab.pressed.connect(_show_tab.bind(CatalogTab.ITEMS))
	%RelicsTab.pressed.connect(_show_tab.bind(CatalogTab.RELICS))
	%ArtifactsTab.pressed.connect(_show_tab.bind(CatalogTab.ARTIFACTS))
	%EnemyOptions.pressed.connect(_open_enemy_picker)
	%DifficultyOptions.pressed.connect(_open_difficulty_picker)
	%OptionPicker.choice_selected.connect(_on_picker_choice_selected)
	%OptionPicker.closed.connect(_clear_picker_target)
	%Seed.value_changed.connect(_on_seed_changed)
	%PlayerHealth.value_changed.connect(_on_player_health_changed)
	%PlayerShield.value_changed.connect(_on_player_shield_changed)
	%BoardWidth.value_changed.connect(_on_board_width_changed)
	%BoardHeight.value_changed.connect(_on_board_height_changed)
	resized.connect(_apply_responsive_layout)
	_configure_numeric_limits()
	_apply_responsive_layout.call_deferred()

func start(existing_configuration: DebugEncounterConfiguration = null) -> void:
	_collect_content()
	configuration = existing_configuration.duplicate_configuration() if existing_configuration != null else _create_default_configuration()
	_normalize_configuration()
	configuring = true
	_populate_enemy_options()
	_populate_difficulty_options()
	_populate_numeric_options()
	configuring = false
	_rebuild_piece_rows()
	_rebuild_item_rows()
	_rebuild_relic_rows()
	_rebuild_artifact_rows()
	_show_tab(CatalogTab.BLOCKS)
	_refresh()
	%EnemyOptions.grab_focus()

func get_configuration() -> DebugEncounterConfiguration:
	return configuration.duplicate_configuration() if configuration != null else null

func _collect_content() -> void:
	enemies.assign(ContentRegistry.enemies)
	difficulties.assign(ContentRegistry.difficulties)
	pieces.assign(ContentRegistry.pieces)
	effects.assign(ContentRegistry.card_effects)
	items.assign(ContentRegistry.items)
	relics.assign(ContentRegistry.relics)
	artifacts.assign(ContentRegistry.artifacts)
	enemies.sort_custom(_definition_precedes)
	difficulties.sort_custom(_definition_precedes)
	pieces.sort_custom(_definition_precedes)
	effects.sort_custom(_definition_precedes)
	items.sort_custom(_definition_precedes)
	relics.sort_custom(_definition_precedes)
	artifacts.sort_custom(_definition_precedes)

func _create_default_configuration() -> DebugEncounterConfiguration:
	var created: DebugEncounterConfiguration = DebugEncounterConfiguration.new()
	created.enemy = rules.default_enemy if rules.default_enemy != null else enemies.front() if not enemies.is_empty() else null
	created.difficulty = RunState.new().difficulty
	created.seed_value = rules.default_seed if rules.default_seed != 0 else 1
	created.player_health = rules.default_player_health if rules.default_player_health > 0 else game_rules.starting_player_health
	created.player_shield = maxi(0, rules.default_player_shield)
	created.board_width = rules.default_board_width if rules.default_board_width > 0 else game_rules.board_width
	created.board_height = rules.default_board_height if rules.default_board_height > 0 else game_rules.board_height
	var default_pool: Array[PieceDefinition] = rules.default_pieces if not rules.default_pieces.is_empty() else pieces
	if default_pool.is_empty():
		return created
	for index: int in rules.default_piece_count:
		created.pieces.append(DebugEncounterPieceSelection.new(default_pool[index % default_pool.size()]))
	return created

func _normalize_configuration() -> void:
	var defaults: DebugEncounterConfiguration = _create_default_configuration()
	if configuration.enemy == null:
		configuration.enemy = defaults.enemy
	if configuration.difficulty == null:
		configuration.difficulty = defaults.difficulty
	if configuration.seed_value == 0:
		configuration.seed_value = defaults.seed_value
	if configuration.player_health <= 0:
		configuration.player_health = defaults.player_health
	if configuration.player_shield < 0:
		configuration.player_shield = defaults.player_shield
	if configuration.board_width <= 0:
		configuration.board_width = defaults.board_width
	if configuration.board_height <= 0:
		configuration.board_height = defaults.board_height
	if configuration.pieces.is_empty():
		for selection: DebugEncounterPieceSelection in defaults.pieces:
			configuration.pieces.append(selection.duplicate_selection())
	_normalize_item_selections()
	_append_missing_content(enemies, configuration.enemy)
	_append_missing_content(difficulties, configuration.difficulty)
	for selection: DebugEncounterPieceSelection in configuration.pieces:
		if selection != null:
			_append_missing_content(pieces, selection.piece)
			_append_missing_content(effects, selection.effect)
	for selection: DebugEncounterItemSelection in configuration.items:
		if selection != null:
			_append_missing_content(items, selection.item)
			_append_missing_content(pieces, selection.bonus_piece)
	for relic: RelicDefinition in configuration.relics:
		_append_missing_content(relics, relic)
	for artifact: BossArtifactDefinition in configuration.artifacts:
		_append_missing_content(artifacts, artifact)
	enemies.sort_custom(_definition_precedes)
	difficulties.sort_custom(_definition_precedes)
	pieces.sort_custom(_definition_precedes)
	effects.sort_custom(_definition_precedes)
	items.sort_custom(_definition_precedes)
	relics.sort_custom(_definition_precedes)
	artifacts.sort_custom(_definition_precedes)

func _normalize_item_selections() -> void:
	var normalized: Array[DebugEncounterItemSelection] = []
	for selection: DebugEncounterItemSelection in configuration.items:
		if selection == null or selection.item == null:
			continue
		var duplicate_item: bool = false
		for existing: DebugEncounterItemSelection in normalized:
			if existing.item == selection.item:
				duplicate_item = true
				break
		if duplicate_item:
			continue
		selection.quantity = clampi(selection.quantity, 1, maxi(1, selection.item.maximum_stack_size))
		if selection.item.category == ItemCategory.Value.BONUS_BLOCK and selection.bonus_piece == null:
			selection.bonus_piece = _default_bonus_piece()
		elif selection.item.category != ItemCategory.Value.BONUS_BLOCK:
			selection.bonus_piece = null
		normalized.append(selection)
	configuration.items = normalized

func _append_missing_content(values: Array, value: Resource) -> void:
	if value != null and not values.has(value):
		values.append(value)

func _populate_enemy_options() -> void:
	var enemy: EnemyDefinition = configuration.enemy
	%EnemyOptions.text = "%s  ▾" % enemy.display_name if enemy != null else "SELECT ENEMY"
	%EnemyOptions.icon = empty_icon
	%EnemyOptions.tooltip_text = _enemy_tooltip(enemy)
	%EnemyOptions.disabled = enemies.is_empty()

func _populate_difficulty_options() -> void:
	var difficulty: DifficultyDefinition = configuration.difficulty
	%DifficultyOptions.text = "%s  ▾" % difficulty.display_name if difficulty != null else "SELECT DIFFICULTY"
	%DifficultyOptions.icon = empty_icon
	%DifficultyOptions.tooltip_text = _difficulty_tooltip(difficulty)
	%DifficultyOptions.disabled = difficulties.is_empty()

func _populate_numeric_options() -> void:
	%Seed.value = configuration.seed_value
	%PlayerHealth.value = configuration.player_health
	%PlayerShield.value = configuration.player_shield
	%BoardWidth.value = configuration.board_width
	%BoardHeight.value = configuration.board_height

func _configure_numeric_limits() -> void:
	%Seed.min_value = 1.0
	%Seed.max_value = maximum_seed_value
	%PlayerHealth.min_value = 1.0
	%PlayerHealth.max_value = maximum_player_health
	%PlayerShield.min_value = 0.0
	%PlayerShield.max_value = maximum_player_shield
	%BoardWidth.min_value = minimum_board_dimension
	%BoardWidth.max_value = maximum_board_dimension
	%BoardHeight.min_value = minimum_board_dimension
	%BoardHeight.max_value = maximum_board_dimension

func _rebuild_piece_rows() -> void:
	for child: Node in %PieceRows.get_children():
		%PieceRows.remove_child(child)
		child.queue_free()
	piece_rows.clear()
	for index: int in configuration.pieces.size():
		var row: DebugPieceLoadoutRow = piece_row_scene.instantiate() as DebugPieceLoadoutRow
		%PieceRows.add_child(row)
		var selection: DebugEncounterPieceSelection = configuration.pieces[index]
		row.configure(index + 1, selection, pieces, effects, rules.allow_incompatible_effects)
		row.set_action_availability(selection != null and configuration.pieces.size() < rules.maximum_piece_count, configuration.pieces.size() > rules.minimum_piece_count)
		row.selection_changed.connect(_on_piece_changed)
		row.piece_picker_requested.connect(_open_piece_picker)
		row.effect_picker_requested.connect(_open_effect_picker)
		row.duplicate_requested.connect(_duplicate_piece)
		row.remove_requested.connect(_remove_piece)
		piece_rows.append(row)
	%AddPiece.disabled = configuration.pieces.size() >= rules.maximum_piece_count

func _rebuild_item_rows() -> void:
	for child: Node in %ItemRows.get_children():
		%ItemRows.remove_child(child)
		child.queue_free()
	item_rows.clear()
	for item: ItemDefinition in items:
		var row: DebugContentToggle = content_toggle_scene.instantiate() as DebugContentToggle
		var selection: DebugEncounterItemSelection = configuration.get_item_selection(item)
		var quantity: int = selection.quantity if selection != null else 0
		%ItemRows.add_child(row)
		row.configure(
			item.display_name,
			item.description,
			selection != null,
			item.accent_color,
			quantity,
			maxi(1, item.maximum_stack_size),
			item.icon
		)
		
		
		
		if item.category == ItemCategory.Value.BONUS_BLOCK:
			var stored_piece: PieceDefinition = selection.bonus_piece if selection != null else _default_bonus_piece()
			var piece_name: String = stored_piece.display_name if stored_piece != null else "SELECT BLOCK"
			var piece_details: String = stored_piece_details_format % [piece_name, stored_piece.base_cells.size()] if stored_piece != null else "Choose the Block stored by this item."
			row.configure_auxiliary(stored_piece_format % piece_name, piece_details, true)
			row.auxiliary_pressed.connect(_open_item_piece_picker.bind(item))
		else:
			row.configure_auxiliary(String(), String(), false)
		row.selection_changed.connect(_on_item_toggled.bind(item))
		row.quantity_changed.connect(_on_item_quantity_changed.bind(item))
		item_rows.append(row)

func _rebuild_relic_rows() -> void:
	for child: Node in %RelicRows.get_children():
		%RelicRows.remove_child(child)
		child.queue_free()
	relic_rows.clear()
	for relic: RelicDefinition in relics:
		var row: DebugContentToggle = content_toggle_scene.instantiate() as DebugContentToggle
		var quantity: int = configuration.relics.count(relic)
		var quantity_limit: int = rules.maximum_repeatable_relic_copies if relic.repeatable else 1
		%RelicRows.add_child(row)
		row.configure(relic.display_name, relic.description, quantity > 0, relic_accent_color, quantity, quantity_limit)
		if relic.repeatable:
			row.quantity_changed.connect(_on_relic_quantity_changed.bind(relic))
		else:
			row.selection_changed.connect(_on_relic_toggled.bind(relic))
		relic_rows.append(row)

func _rebuild_artifact_rows() -> void:
	for child: Node in %ArtifactRows.get_children():
		%ArtifactRows.remove_child(child)
		child.queue_free()
	artifact_rows.clear()
	for artifact: BossArtifactDefinition in artifacts:
		var row: DebugContentToggle = content_toggle_scene.instantiate() as DebugContentToggle
		var description: String = artifact.benefit
		if not artifact.drawback.is_empty():
			description += "\n%s: %s" % [artifact_drawback_label, artifact.drawback]
		%ArtifactRows.add_child(row)
		row.configure(artifact.display_name, description, configuration.artifacts.has(artifact), artifact.accent_color)
		row.selection_changed.connect(_on_artifact_toggled.bind(artifact))
		artifact_rows.append(row)

func _show_tab(tab: CatalogTab) -> void:
	%OptionPicker.close_picker()
	active_tab = tab
	%BlocksContent.visible = tab == CatalogTab.BLOCKS
	%ItemsScroll.visible = tab == CatalogTab.ITEMS
	%RelicsScroll.visible = tab == CatalogTab.RELICS
	%ArtifactsScroll.visible = tab == CatalogTab.ARTIFACTS
	%BlocksTab.theme_type_variation = &"PrimaryButton" if tab == CatalogTab.BLOCKS else &"SecondaryButton"
	%ItemsTab.theme_type_variation = &"PrimaryButton" if tab == CatalogTab.ITEMS else &"SecondaryButton"
	%RelicsTab.theme_type_variation = &"PrimaryButton" if tab == CatalogTab.RELICS else &"SecondaryButton"
	%ArtifactsTab.theme_type_variation = &"PrimaryButton" if tab == CatalogTab.ARTIFACTS else &"SecondaryButton"
	_clear_scroll_touch()

func _open_enemy_picker() -> void:
	var choices: Array[DebugOptionChoice] = []
	for enemy: EnemyDefinition in enemies:
		choices.append(DebugOptionChoice.new(enemy.display_name, _enemy_tooltip(enemy), empty_icon))
	_show_picker(PickerTarget.ENEMY, null, "SELECT ENEMY", choices, enemies.find(configuration.enemy))

func _open_difficulty_picker() -> void:
	var choices: Array[DebugOptionChoice] = []
	for difficulty: DifficultyDefinition in difficulties:
		choices.append(DebugOptionChoice.new(difficulty.display_name, _difficulty_tooltip(difficulty), empty_icon))
	_show_picker(PickerTarget.DIFFICULTY, null, "SELECT DIFFICULTY", choices, difficulties.find(configuration.difficulty))

func _open_piece_picker(row: DebugPieceLoadoutRow) -> void:
	if row == null:
		return
	_show_picker(PickerTarget.PIECE, row, "SELECT BLOCK", row.get_piece_picker_choices(), row.get_selected_piece_index())

func _open_effect_picker(row: DebugPieceLoadoutRow) -> void:
	if row == null:
		return
	_show_picker(PickerTarget.EFFECT, row, "SELECT EFFECT", row.get_effect_picker_choices(), row.get_selected_effect_index())

func _open_item_piece_picker(_row: DebugContentToggle, item: ItemDefinition) -> void:
	if item == null or pieces.is_empty():
		return
	var choices: Array[DebugOptionChoice] = []
	for piece: PieceDefinition in pieces:
		choices.append(DebugOptionChoice.new(piece.display_name, stored_piece_details_format % [piece.display_name, piece.base_cells.size()], empty_icon))
	var selection: DebugEncounterItemSelection = configuration.get_item_selection(item)
	var selected_piece: PieceDefinition = selection.bonus_piece if selection != null else _default_bonus_piece()
	picker_item = item
	_show_picker(PickerTarget.ITEM_PIECE, null, "SELECT STORED BLOCK", choices, pieces.find(selected_piece))

func _show_picker(target: PickerTarget, row: DebugPieceLoadoutRow, title: String, choices: Array[DebugOptionChoice], selected_choice_index: int) -> void:
	_clear_scroll_touch()
	picker_target = target
	picker_row = row
	if target != PickerTarget.ITEM_PIECE:
		picker_item = null
	%OptionPicker.open_picker(title, choices, selected_choice_index)

func _on_picker_choice_selected(index: int) -> void:
	match picker_target:
		PickerTarget.ENEMY:
			_on_enemy_selected(index)
		PickerTarget.DIFFICULTY:
			_on_difficulty_selected(index)
		PickerTarget.PIECE:
			if is_instance_valid(picker_row):
				picker_row.select_piece_option(index)
		PickerTarget.EFFECT:
			if is_instance_valid(picker_row):
				picker_row.select_effect_option(index)
		PickerTarget.ITEM_PIECE:
			_on_item_piece_selected(index)
	_clear_picker_target()

func _clear_picker_target() -> void:
	picker_target = PickerTarget.NONE
	picker_row = null
	picker_item = null

func _add_piece() -> void:
	if configuration.pieces.size() >= rules.maximum_piece_count:
		return
	var default_pool: Array[PieceDefinition] = rules.default_pieces if not rules.default_pieces.is_empty() else pieces
	if default_pool.is_empty():
		return
	var piece: PieceDefinition = default_pool[configuration.pieces.size() % default_pool.size()]
	configuration.pieces.append(DebugEncounterPieceSelection.new(piece))
	_rebuild_piece_rows()
	_refresh()

func _duplicate_piece(row: DebugPieceLoadoutRow) -> void:
	if configuration.pieces.size() >= rules.maximum_piece_count:
		return
	var index: int = piece_rows.find(row)
	if index < 0 or configuration.pieces[index] == null:
		return
	configuration.pieces.insert(index + 1, configuration.pieces[index].duplicate_selection())
	_rebuild_piece_rows()
	_refresh()

func _remove_piece(row: DebugPieceLoadoutRow) -> void:
	if configuration.pieces.size() <= rules.minimum_piece_count:
		return
	var index: int = piece_rows.find(row)
	if index < 0:
		return
	configuration.pieces.remove_at(index)
	_rebuild_piece_rows()
	_refresh()

func _on_piece_changed(_row: DebugPieceLoadoutRow) -> void:
	_refresh()

func _on_item_toggled(_row: DebugContentToggle, selected: bool, item: ItemDefinition) -> void:
	if selected:
		if _ensure_item_selection(item) == null:
			_rebuild_item_rows()
	else:
		configuration.remove_item(item)
	_refresh()

func _on_item_quantity_changed(_row: DebugContentToggle, quantity: int, item: ItemDefinition) -> void:
	if quantity <= 0:
		configuration.remove_item(item)
		_refresh()
		return
	var selection: DebugEncounterItemSelection = _ensure_item_selection(item)
	if selection == null:
		_rebuild_item_rows()
		_refresh()
		return
	selection.quantity = clampi(quantity, 1, maxi(1, item.maximum_stack_size))
	_refresh()

func _on_item_piece_selected(index: int) -> void:
	if picker_item == null or index < 0 or index >= pieces.size():
		return
	var selection: DebugEncounterItemSelection = _ensure_item_selection(picker_item)
	if selection == null:
		return
	selection.bonus_piece = pieces[index]
	_rebuild_item_rows()
	_refresh()

func _ensure_item_selection(item: ItemDefinition) -> DebugEncounterItemSelection:
	if item == null:
		return null
	var selection: DebugEncounterItemSelection = configuration.get_item_selection(item)
	if selection != null:
		return selection
	if configuration.items.size() >= _maximum_item_slots():
		return null
	selection = DebugEncounterItemSelection.new(item)
	if item.category == ItemCategory.Value.BONUS_BLOCK:
		selection.bonus_piece = _default_bonus_piece()
	configuration.items.append(selection)
	return selection

func _default_bonus_piece() -> PieceDefinition:
	if configuration != null:
		for selection: DebugEncounterPieceSelection in configuration.pieces:
			if selection != null and selection.piece != null:
				return selection.piece
	for piece: PieceDefinition in pieces:
		if piece != null and piece.is_valid():
			return piece
	return null

func _maximum_item_slots() -> int:
	return mini(rules.maximum_item_slots, game_rules.maximum_item_slots)

func _on_relic_toggled(_row: DebugContentToggle, selected: bool, relic: RelicDefinition) -> void:
	if selected and not configuration.relics.has(relic):
		configuration.relics.append(relic)
	elif not selected:
		configuration.relics.erase(relic)
	_refresh()

func _on_relic_quantity_changed(_row: DebugContentToggle, quantity: int, relic: RelicDefinition) -> void:
	while configuration.relics.has(relic):
		configuration.relics.erase(relic)
	for _stack_index: int in clampi(quantity, 0, rules.maximum_repeatable_relic_copies):
		configuration.relics.append(relic)
	_refresh()

func _on_artifact_toggled(_row: DebugContentToggle, selected: bool, artifact: BossArtifactDefinition) -> void:
	if selected and not configuration.artifacts.has(artifact):
		configuration.artifacts.append(artifact)
	elif not selected:
		configuration.artifacts.erase(artifact)
	_refresh()

func _on_enemy_selected(index: int) -> void:
	if configuring or index < 0 or index >= enemies.size():
		return
	configuration.enemy = enemies[index]
	_populate_enemy_options()
	_refresh()

func _on_difficulty_selected(index: int) -> void:
	if configuring or index < 0 or index >= difficulties.size():
		return
	configuration.difficulty = difficulties[index]
	_populate_difficulty_options()
	_refresh()

func _on_seed_changed(value: float) -> void:
	if not configuring and configuration != null:
		configuration.seed_value = roundi(value)
		_refresh()

func _on_player_health_changed(value: float) -> void:
	if not configuring and configuration != null:
		configuration.player_health = roundi(value)
		_refresh()

func _on_player_shield_changed(value: float) -> void:
	if not configuring and configuration != null:
		configuration.player_shield = roundi(value)
		_refresh()

func _on_board_width_changed(value: float) -> void:
	if not configuring and configuration != null:
		configuration.board_width = roundi(value)
		_refresh()

func _on_board_height_changed(value: float) -> void:
	if not configuring and configuration != null:
		configuration.board_height = roundi(value)
		_refresh()

func _refresh() -> void:
	if configuration == null:
		return
	var enemy_name: String = configuration.enemy.display_name if configuration.enemy != null else "NO ENEMY"
	var effect_count: int = 0
	for selection: DebugEncounterPieceSelection in configuration.pieces:
		if selection != null and selection.resolved_effect() != null:
			effect_count += 1
	%EnemyDetails.text = _enemy_tooltip(configuration.enemy)
	%SelectionSummary.text = selection_summary_format % [enemy_name, configuration.pieces.size(), effect_count, configuration.items.size(), configuration.relics.size(), configuration.artifacts.size()]
	var validation_error: String = DebugEncounterBuilder.new().validate(configuration, rules, game_rules)
	%Validation.text = validation_error
	%Validation.visible = not validation_error.is_empty()
	%StartTest.disabled = not validation_error.is_empty()

func _request_encounter() -> void:
	var validation_error: String = DebugEncounterBuilder.new().validate(configuration, rules, game_rules)
	if not validation_error.is_empty():
		%Validation.text = validation_error
		%Validation.visible = true
		return
	encounter_requested.emit(configuration.duplicate_configuration())

func _reset_configuration() -> void:
	configuration = _create_default_configuration()
	configuring = true
	_populate_enemy_options()
	_populate_difficulty_options()
	_populate_numeric_options()
	configuring = false
	_rebuild_piece_rows()
	_rebuild_item_rows()
	_rebuild_relic_rows()
	_rebuild_artifact_rows()
	_refresh()

func _enemy_tooltip(enemy: EnemyDefinition) -> String:
	if enemy == null:
		return "Select an enemy to test."
	var role_index: int = clampi(int(enemy.encounter_role), 0, enemy_role_names.size() - 1)
	var role_name: String = enemy_role_names[role_index] if not enemy_role_names.is_empty() else "ENEMY"
	return enemy_summary_format % [role_name, enemy.maximum_health, enemy.minimum_act, enemy.maximum_act, enemy.attack_interval]

func _difficulty_tooltip(difficulty: DifficultyDefinition) -> String:
	if difficulty == null:
		return "Select a difficulty."
	return difficulty_summary_format % [difficulty.enemy_health_multiplier, difficulty.attack_interval_modifier, difficulty.starting_blockers, difficulty.draw_count_modifier]

func _definition_precedes(left: Resource, right: Resource) -> bool:
	if left == null:
		return false
	if right == null:
		return true
	var left_name: String = String(left.get("display_name"))
	var right_name: String = String(right.get("display_name"))
	var name_order: int = left_name.naturalnocasecmp_to(right_name)
	return left.resource_path < right.resource_path if name_order == 0 else name_order < 0

func _apply_responsive_layout() -> void:
	if is_node_ready():
		var mobile: bool = size.x < mobile_breakpoint_width
		%SetupGrid.columns = 2 if mobile else 4
		%DebugBadge.visible = not mobile
		%Back.custom_minimum_size = Vector2(0.0, desktop_back_minimum_size.y) if mobile else desktop_back_minimum_size
		%Reset.custom_minimum_size = Vector2(0.0, desktop_reset_minimum_size.y) if mobile else desktop_reset_minimum_size
		%StartTest.custom_minimum_size = Vector2(0.0, desktop_start_minimum_size.y) if mobile else desktop_start_minimum_size
		var field_index: int = 0
		for child: Node in %SetupGrid.get_children():
			var field: Control = child as Control
			if field == null:
				continue
			field.custom_minimum_size = Vector2(0.0, desktop_setup_field_minimum_sizes[field_index].y) if mobile else desktop_setup_field_minimum_sizes[field_index]
			field_index += 1

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or %OptionPicker.visible:
		return
	var scroll: ScrollContainer = _active_scroll()
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and scroll.get_global_rect().has_point(touch.position):
			scroll_touch_index = touch.index
			scroll_touch_start = touch.position
			scroll_touch_axis = Vector2i.ZERO
		elif not touch.pressed and touch.index == scroll_touch_index:
			if scroll_touch_axis != Vector2i.ZERO:
				get_viewport().set_input_as_handled()
			_clear_scroll_touch()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index != scroll_touch_index:
			return
		var movement: Vector2 = drag.position - scroll_touch_start
		if scroll_touch_axis == Vector2i.ZERO and movement.length() >= touch_scroll_direction_threshold:
			if absf(movement.y) > absf(movement.x):
				scroll_touch_axis = Vector2i.DOWN
			elif active_tab == CatalogTab.BLOCKS:
				scroll_touch_axis = Vector2i.RIGHT
			else:
				_clear_scroll_touch()
				return
		if scroll_touch_axis == Vector2i.DOWN:
			scroll.scroll_vertical -= roundi(drag.relative.y)
			get_viewport().set_input_as_handled()
		elif scroll_touch_axis == Vector2i.RIGHT:
			scroll.scroll_horizontal -= roundi(drag.relative.x)
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		if %OptionPicker.visible:
			%OptionPicker.close_picker()
		else:
			back_requested.emit()

func _active_scroll() -> ScrollContainer:
	match active_tab:
		CatalogTab.ITEMS:
			return %ItemsScroll
		CatalogTab.RELICS:
			return %RelicsScroll
		CatalogTab.ARTIFACTS:
			return %ArtifactsScroll
		_:
			return %BlocksScroll

func _clear_scroll_touch() -> void:
	scroll_touch_index = -1
	scroll_touch_start = Vector2.ZERO
	scroll_touch_axis = Vector2i.ZERO
