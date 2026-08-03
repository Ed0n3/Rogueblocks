class_name DebugOptionChoice
extends RefCounted

var title: String
var description: String
var icon: Texture2D

func _init(choice_title: String = String(), choice_description: String = String(), choice_icon: Texture2D = null) -> void:
	title = choice_title
	description = choice_description
	icon = choice_icon
