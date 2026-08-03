extends Control

func _ready() -> void:
	TutorialTargetRegistry.register_target(&"route.available_node", %AvailableNodes)
	TutorialTargetRegistry.register_target(&"route.piece_pool_button", %Pieces)
	TutorialTargetRegistry.register_target(&"route.relic_button", %Relics)
	TutorialTargetRegistry.register_target(&"route.shards", %Shards)
	if TutorialService.active_definition != null:
		TutorialService.cancel_active()
	call_deferred("_start_showcase")

func _start_showcase() -> void:
	TutorialService.start_tutorial(&"tutorial_route_basics", true)
