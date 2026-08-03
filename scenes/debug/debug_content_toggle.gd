class_name DebugContentToggle
extends PanelContainer

signal selection_changed(row: DebugContentToggle, selected: bool)
signal quantity_changed(row: DebugContentToggle, quantity: int)
signal auxiliary_pressed(row: DebugContentToggle)

const EMPTY_ICON: Texture2D = preload("res://assets/icons/empty_texture.tres")

var selected_value: bool = false
var quantity_value: int = 0
var maximum_quantity: int = 1
var configuring: bool = false
var title_text: String
var description_text: String

func _ready() -> void:
	%Selected.toggled.connect(_on_toggled)
	%Decrease.pressed.connect(_decrease_quantity)
	%Increase.pressed.connect(_increase_quantity)
	%Auxiliary.pressed.connect(func() -> void: auxiliary_pressed.emit(self))

func configure(
	title: String,
	description: String,
	selected: bool,
	accent: Color = Color("7ee7d8"),
	quantity: int = -1,
	quantity_limit: int = 1,
	icon: Texture2D = null
) -> void:
	configuring = true
	title_text = title
	description_text = description
	maximum_quantity = maxi(1, quantity_limit)
	quantity_value = clampi(quantity if quantity >= 0 else 1 if selected else 0, 0, maximum_quantity)
	selected_value = quantity_value > 0
	%Selected.text = title
	%Selected.icon = icon if icon != null else EMPTY_ICON
	%Selected.button_pressed = selected_value
	%QuantityControls.visible = maximum_quantity > 1
	%Description.text = description
	%Accent.color = accent
	%Selected.add_theme_color_override(&"font_color", accent)
	%Selected.add_theme_color_override(&"font_hover_color", accent.lightened(0.15))
	%Selected.add_theme_color_override(&"font_pressed_color", accent.lightened(0.15))
	_refresh_quantity()
	configuring = false

func configure_auxiliary(label: String, details: String, visible: bool) -> void:
	%Auxiliary.visible = visible
	%Auxiliary.text = label
	%Auxiliary.icon = EMPTY_ICON
	%Auxiliary.tooltip_text = details

func is_selected() -> bool:
	return selected_value

func get_quantity() -> int:
	return quantity_value

func set_quantity(quantity: int, notify: bool = false) -> void:
	var resolved_quantity: int = clampi(quantity, 0, maximum_quantity)
	if quantity_value == resolved_quantity:
		return
	quantity_value = resolved_quantity
	selected_value = quantity_value > 0
	configuring = true
	%Selected.button_pressed = selected_value
	configuring = false
	_refresh_quantity()
	if notify:
		quantity_changed.emit(self, quantity_value)

func _on_toggled(selected: bool) -> void:
	if configuring:
		return
	selected_value = selected
	if maximum_quantity > 1:
		set_quantity(1 if selected else 0, true)
	else:
		quantity_value = 1 if selected else 0
		selection_changed.emit(self, selected)

func _decrease_quantity() -> void:
	set_quantity(quantity_value - 1, true)

func _increase_quantity() -> void:
	set_quantity(quantity_value + 1, true)

func _refresh_quantity() -> void:
	%Quantity.text = str(quantity_value)
	%Decrease.disabled = quantity_value <= 0
	%Increase.disabled = quantity_value >= maximum_quantity
	var details: String = "%s\n\n%s" % [title_text, description_text]
	if maximum_quantity > 1:
		details += "\n\nStack count: %d / %d" % [quantity_value, maximum_quantity]
	tooltip_text = details
	%Selected.tooltip_text = details
	%Description.tooltip_text = details
	%Quantity.tooltip_text = "Stack count for %s" % title_text
	%Decrease.tooltip_text = "Remove one %s stack" % title_text
	%Increase.tooltip_text = "Add one %s stack" % title_text
