class_name CounterDefinition
extends Resource

@export var display_name: String
@export_multiline var description: String
## Optional compact objective shown in the enemy intent row. The counter type supplies a fallback when empty.
@export var short_intent_description: String = ""
@export var counter_type: CounterType.Value = CounterType.Value.CLEAR_TOTAL_LINES
@export var duration_turns: int = 2
@export var required_progress: int = 1
@export var partial_success_threshold: int = 0
@export var target_area_size: Vector2i = Vector2i(3, 3)
@export var success_effects: Array[GameplayEffect] = []
@export var partial_success_effects: Array[GameplayEffect] = []
@export var failure_effects: Array[GameplayEffect] = []
@export var valid_item_counter_tags: Array[StringName] = []
