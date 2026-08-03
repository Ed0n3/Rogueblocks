class_name HubScreen
extends Control

signal new_run_requested(difficulty: DifficultyDefinition)
signal continue_run_requested()
signal resume_fight_requested()
signal upgrades_requested()
signal collection_requested()
signal statistics_requested()
signal daily_requested()
signal settings_requested()
signal tutorials_requested()
signal main_menu_requested()

enum PendingRunRequest { NONE, NEW_RUN, DAILY_RUN }

var pending_run_request: PendingRunRequest = PendingRunRequest.NONE
var pending_difficulty: DifficultyDefinition

func _ready() -> void:
	%NewRun.pressed.connect(_request_new_run)
	%ContinueRun.pressed.connect(func() -> void: continue_run_requested.emit())
	%ResumeFight.pressed.connect(func() -> void: resume_fight_requested.emit())
	%Upgrades.pressed.connect(func() -> void: upgrades_requested.emit())
	%Collection.pressed.connect(func() -> void: collection_requested.emit())
	%Statistics.pressed.connect(func() -> void: statistics_requested.emit())
	%Daily.pressed.connect(_request_daily_run)
	%Settings.pressed.connect(func() -> void: settings_requested.emit())
	%Tutorials.pressed.connect(func() -> void: tutorials_requested.emit())
	%Back.pressed.connect(func() -> void: main_menu_requested.emit())
	%ConfirmRunReplacement.confirmed.connect(_confirm_run_replacement)
	%ConfirmRunReplacement.canceled.connect(_cancel_run_replacement)
	for definition: DifficultyDefinition in SaveService.profile.unlocked_difficulties:
		%Difficulty.add_item(definition.display_name)
		%Difficulty.set_item_metadata(%Difficulty.item_count - 1, definition)
		%Difficulty.set_item_icon(%Difficulty.item_count - 1, load("res://assets/icons/empty_texture.tres") as Texture2D)
	refresh()
	var motion: MotionSettings = MotionSettings.from_saved_settings(SaveService.settings)
	MotionPresets.pop_in(%ExpeditionCard, 0.04, motion)
	MotionPresets.pop_in(%UpgradeCard, 0.1, motion)
	MotionPresets.pop_in(%DailyCard, 0.16, motion)
	TutorialService.enter_screen(TutorialScreen.Value.HUB, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.HUB_PERMANENT_UPGRADES, %Upgrades, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.HUB_DAILY_CHALLENGE, %Daily, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.HUB_RUN_CONTROLS, %ExpeditionCard, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.HUB_ARCHIVE, $Margin/Layout/Dashboard/ArchiveCard, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.HUB_HEADER_CONTROLS, $Margin/Layout/TopBar, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.HUB_MAIN_MENU, %Back, self)
	TutorialService.publish(TutorialEventId.Value.PROGRESSION_HUB_OPENED)
	tree_exiting.connect(_unregister_tutorial_target, CONNECT_ONE_SHOT)

func _request_new_run() -> void:
	pending_difficulty = %Difficulty.get_item_metadata(%Difficulty.selected) as DifficultyDefinition
	_request_run(PendingRunRequest.NEW_RUN)

func _request_daily_run() -> void:
	_request_run(PendingRunRequest.DAILY_RUN)

func _request_run(request: PendingRunRequest) -> void:
	if not SaveService.has_valid_active_run():
		_emit_run_request(request)
		return
	pending_run_request = request
	%ConfirmRunReplacement.popup_centered()

func _confirm_run_replacement() -> void:
	var request: PendingRunRequest = pending_run_request
	pending_run_request = PendingRunRequest.NONE
	_emit_run_request(request)

func _cancel_run_replacement() -> void:
	pending_run_request = PendingRunRequest.NONE

func _emit_run_request(request: PendingRunRequest) -> void:
	match request:
		PendingRunRequest.NEW_RUN:
			new_run_requested.emit(pending_difficulty)
		PendingRunRequest.DAILY_RUN:
			daily_requested.emit()

func _unregister_tutorial_target() -> void:
	TutorialService.leave_screen(TutorialScreen.Value.HUB, self)
	TutorialTargetRegistry.unregister_owner(self)

func refresh() -> void:
	%Fragments.text = "FRAGMENTS  %d" % SaveService.profile.fragments
	var has_active_run: bool = SaveService.has_valid_active_run()
	var has_active_fight: bool = SaveService.has_resumable_encounter()
	%ContinueRun.disabled = not has_active_run or has_active_fight
	%ResumeFight.disabled = not has_active_fight
	%ProfileStatus.text = "%d runs  |  %d victories  |  best score %d%s" % [SaveService.profile.completed_runs, SaveService.profile.victories, SaveService.profile.highest_score, "  |  DEBUG PROFILE" if SaveService.profile.debug_modified else ""]
	%ContinueRun.visible = has_active_run and not has_active_fight
	%ResumeFight.visible = has_active_fight
	var purchased: int = 0
	for progress: UpgradeLevelState in SaveService.profile.upgrade_progress:
		purchased += progress.level
	%UpgradeProgress.text = "%d upgrade levels active\n%d Blocks in reserve\n%d labyrinth regions" % [purchased, SaveService.profile.upgrade_piece_inventory.get_total_quantity(), ContentRegistry.upgrades.size()]
