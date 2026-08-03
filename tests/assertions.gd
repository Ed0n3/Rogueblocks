class_name TestAssertions
extends RefCounted

var passed: int = 0
var failed: int = 0

func equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		passed += 1
	else:
		failed += 1
		push_error("%s: expected %s, received %s" % [label, expected, actual])

func truthy(value: bool, label: String) -> void:
	equal(value, true, label)

func falsy(value: bool, label: String) -> void:
	equal(value, false, label)
