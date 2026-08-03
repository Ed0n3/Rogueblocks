class_name AttackIntentView
extends Control

var countdown: int = 0
var maximum: int = 0
var intent_label: String = "ATTACK"
var accent_color: Color = Color("f1c75b")
var pulse_phase: float = 0.0

func set_intent(remaining: int, interval: int, label: String = "ATTACK") -> void:
	countdown = maxi(0, remaining)
	maximum = maxi(1, interval)
	intent_label = label
	set_process(countdown <= 1)
	queue_redraw()

func _process(delta: float) -> void:
	pulse_phase += delta * 6.0
	queue_redraw()

func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(0.0, 17.0), intent_label, HORIZONTAL_ALIGNMENT_LEFT, 90.0, 14, Color("a3acc5"))
	var start_x: float = 98.0
	for index: int in maximum:
		var active: bool = index < countdown
		var final_active: bool = active and countdown == 1 and index == 0
		var radius: float = 5.0 + (1.5 * (0.5 + 0.5 * sin(pulse_phase)) if final_active else 0.0)
		var color: Color = accent_color if active else Color("303b5d")
		draw_circle(Vector2(start_x + float(index) * 18.0, 12.0), radius, color)
