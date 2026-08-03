class_name AfterClearContext
extends RefCounted

var run_state: RunState
var clear_result: ClearResult

func _init(run: RunState, clear: ClearResult) -> void:
	run_state = run
	clear_result = clear
