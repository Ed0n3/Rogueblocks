class_name InfoScreen
extends Control

signal back_requested()

func start(title: String, body: String) -> void:
	%Title.text = title
	%Body.text = body
	%Back.pressed.connect(func() -> void: back_requested.emit())
