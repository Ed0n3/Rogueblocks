class_name TutorialInputFormatter
extends RefCounted

static func format_text(value: String) -> String:
	var result: String = value
	for action_name: StringName in InputMap.get_actions():
		var placeholder: String = "{%s}" % action_name
		if result.contains(placeholder):
			result = result.replace(placeholder, action_label(action_name))
	return result

static func action_label(action: StringName) -> String:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	if events.is_empty():
		return "[%s]" % String(action).capitalize()
	var label: String = events[0].as_text().replace(" (Physical)", "")
	return "[%s]" % label
