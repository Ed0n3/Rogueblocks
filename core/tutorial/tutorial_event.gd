class_name TutorialEvent
extends RefCounted

var type: TutorialEventId.Value = TutorialEventId.Value.NONE
var source: Resource
var piece: PieceDefinition
var status: StatusDefinition
var item: ItemDefinition
var relic: RelicDefinition
var artifact: BossArtifactDefinition
var route_node: RouteNodeState
var difficulty: DifficultyDefinition
var target: EffectTarget.Value = EffectTarget.Value.PLAYER
var screen: TutorialScreen.Value = TutorialScreen.Value.NONE
var int_value: int = 0
var secondary_int_value: int = 0
var float_value: float = 0.0
var bool_value: bool = false
var cells: Array[Vector2i] = []

func _init(event_type: TutorialEventId.Value = TutorialEventId.Value.NONE) -> void:
	type = event_type

func duplicate_event() -> TutorialEvent:
	var copy: TutorialEvent = TutorialEvent.new(type)
	copy.source = source
	copy.piece = piece
	copy.status = status
	copy.item = item
	copy.relic = relic
	copy.artifact = artifact
	copy.route_node = route_node
	copy.difficulty = difficulty
	copy.target = target
	copy.screen = screen
	copy.int_value = int_value
	copy.secondary_int_value = secondary_int_value
	copy.float_value = float_value
	copy.bool_value = bool_value
	copy.cells = cells.duplicate()
	return copy
