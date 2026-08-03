class_name PauseScreen
extends Control

signal resume_requested()
signal restart_requested()
signal settings_requested()
signal main_menu_requested()

@export_category("Test Area")
@export var test_area_restart_label: String = "Restart Test"
@export var test_area_return_label: String = "Return to Test Area"
@export_multiline var test_area_restart_confirmation: String = "Restart this test?\nCurrent test progress isn't saved."
@export_multiline var test_area_return_confirmation: String = "Return to the Test Area?\nCurrent test progress isn't saved."

func _ready() -> void:
	%Resume.pressed.connect(func() -> void: resume_requested.emit())
	%Restart.pressed.connect(func() -> void: %ConfirmRestart.popup_centered())
	%Settings.pressed.connect(func() -> void: settings_requested.emit())
	%MainMenu.pressed.connect(func() -> void: %ConfirmMenu.popup_centered())
	%ConfirmRestart.confirmed.connect(func() -> void: restart_requested.emit())
	%ConfirmMenu.confirmed.connect(func() -> void: main_menu_requested.emit())

func configure_for_test_area() -> void:
	%Restart.tooltip_text = test_area_restart_label
	%MainMenu.tooltip_text = test_area_return_label
	%ConfirmRestart.dialog_text = test_area_restart_confirmation
	%ConfirmMenu.dialog_text = test_area_return_confirmation
