class_name TutorialTargetRegistration
extends RefCounted

var key: TutorialTargetKey.Value
var node_reference: WeakRef
var owner_reference: WeakRef

func _init(target_key: TutorialTargetKey.Value = TutorialTargetKey.Value.NONE, node: Node = null, owner: Node = null) -> void:
	key = target_key
	node_reference = weakref(node) if node != null else null
	owner_reference = weakref(owner if owner != null else node) if node != null else null

func get_node() -> Node:
	return node_reference.get_ref() as Node if node_reference != null else null

func get_owner() -> Node:
	return owner_reference.get_ref() as Node if owner_reference != null else null
