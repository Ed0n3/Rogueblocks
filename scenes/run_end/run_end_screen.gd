class_name RunEndScreen
extends Control

signal new_run_requested()
signal retry_requested()
signal main_menu_requested()
signal save_retry_requested()

@export_multiline var persistence_error_message: String = "Your run result could not be saved. Retry before leaving this screen."

func start(run_state: RunState, won: bool, reason: String, persistence_failed: bool = false) -> void:
	%Result.text = "RUN VICTORY" if won else "RUN DEFEAT"
	%Reason.text = "" if won else reason
	%Statistics.text = "Final score        %d\nFights won         %d\nLines cleared      %d\nCross clears       %d\nPerfect clears     %d\nHighest combo      %d\nBlocks placed      %d\nRun seed           %d" % [run_state.score, run_state.enemies_defeated, run_state.cleared_lines, run_state.cross_clears, run_state.perfect_clears, run_state.highest_combo, run_state.placements, run_state.seed_value]
	%PersistenceError.text = persistence_error_message
	%PersistenceError.visible = persistence_failed
	%RetrySave.visible = persistence_failed
	%NewRun.visible = not persistence_failed
	%Retry.visible = not persistence_failed
	%MainMenu.visible = not persistence_failed
	%NewRun.pressed.connect(func() -> void: new_run_requested.emit())
	%Retry.pressed.connect(func() -> void: retry_requested.emit())
	%MainMenu.pressed.connect(func() -> void: main_menu_requested.emit())
	%RetrySave.pressed.connect(func() -> void: save_retry_requested.emit())
