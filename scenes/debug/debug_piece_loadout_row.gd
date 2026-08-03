class_name DebugPieceLoadoutRow
extends PanelContainer

signal selection_changed(row: DebugPieceLoadoutRow)
signal piece_picker_requested(row: DebugPieceLoadoutRow)
signal effect_picker_requested(row: DebugPieceLoadoutRow)
signal duplicate_requested(row: DebugPieceLoadoutRow)
signal remove_requested(row: DebugPieceLoadoutRow)

const EMPTY_ICON: Texture2D = preload("res://assets/icons/empty_texture.tres")

@export var dropdown_suffix: String = "  ▾"
@export var filler_title: String = "FILLER PIECE"
@export var filler_description: String = "No intrinsic Block effect."
@export var permanent_suffix: String = "  |  PERMANENT"

var selection: DebugEncounterPieceSelection
var piece_options: Array[PieceDefinition] = []
var effect_options: Array[PieceCardEffectDefinition] = []
var available_pieces: Array[PieceDefinition] = []
var available_effects: Array[PieceCardEffectDefinition] = []
var allow_incompatible_effects: bool = false

func _ready() -> void:
	%PieceOptions.pressed.connect(func() -> void: piece_picker_requested.emit(self))
	%EffectOptions.pressed.connect(func() -> void: effect_picker_requested.emit(self))
	%Duplicate.pressed.connect(func() -> void: duplicate_requested.emit(self))
	%Remove.pressed.connect(func() -> void: remove_requested.emit(self))

func configure(order: int, piece_selection: DebugEncounterPieceSelection, pieces: Array[PieceDefinition], effects: Array[PieceCardEffectDefinition], include_incompatible_effects: bool = false) -> void:
	selection = piece_selection
	allow_incompatible_effects = include_incompatible_effects
	available_pieces.assign(pieces)
	available_effects.assign(effects)
	available_pieces.sort_custom(_piece_precedes)
	available_effects.sort_custom(_effect_precedes)
	if selection != null and selection.piece != null and not available_pieces.has(selection.piece):
		available_pieces.append(selection.piece)
		available_pieces.sort_custom(_piece_precedes)
	%Order.text = "%02d" % maxi(1, order)
	_populate_piece_options()
	_normalize_effect()
	_populate_effect_options()
	_refresh_icons()

func set_action_availability(can_duplicate: bool, can_remove: bool) -> void:
	%Duplicate.disabled = not can_duplicate
	%Remove.disabled = not can_remove

func get_piece_picker_choices() -> Array[DebugOptionChoice]:
	var choices: Array[DebugOptionChoice] = []
	for piece: PieceDefinition in piece_options:
		var piece_icon: Texture2D = piece.upgrade_board_icon if piece.upgrade_board_icon != null else EMPTY_ICON
		choices.append(DebugOptionChoice.new(piece.display_name, _piece_tooltip(piece), piece_icon))
	return choices

func get_effect_picker_choices() -> Array[DebugOptionChoice]:
	var choices: Array[DebugOptionChoice] = []
	var piece: PieceDefinition = selection.piece if selection != null else null
	for effect: PieceCardEffectDefinition in effect_options:
		if effect == null:
			choices.append(DebugOptionChoice.new(filler_title, filler_description, EMPTY_ICON))
		else:
			var effect_description: String = effect.description
			if piece != null and piece.permanent_card_effect == effect:
				effect_description += "\n\nThis Block's permanent effect cannot be changed."
			var effect_icon: Texture2D = effect.icon if effect.icon != null else EMPTY_ICON
			choices.append(DebugOptionChoice.new(effect.display_name, effect_description, effect_icon))
	return choices

func get_selected_piece_index() -> int:
	return piece_options.find(selection.piece) if selection != null else -1

func get_selected_effect_index() -> int:
	if selection == null:
		return -1
	var resolved_effect: PieceCardEffectDefinition = selection.resolved_effect()
	return effect_options.find(resolved_effect)

func select_piece_option(index: int) -> void:
	if selection == null or index < 0 or index >= piece_options.size():
		return
	selection.piece = piece_options[index]
	_normalize_effect()
	_populate_piece_options()
	_populate_effect_options()
	_refresh_icons()
	selection_changed.emit(self)

func select_effect_option(index: int) -> void:
	if selection == null or index < 0 or index >= effect_options.size():
		return
	selection.effect = effect_options[index]
	_populate_effect_options()
	_refresh_icons()
	selection_changed.emit(self)

func _populate_piece_options() -> void:
	piece_options.clear()
	for piece: PieceDefinition in available_pieces:
		if piece != null:
			piece_options.append(piece)
	var piece: PieceDefinition = selection.piece if selection != null else null
	var piece_icon: Texture2D = piece.upgrade_board_icon if piece != null and piece.upgrade_board_icon != null else EMPTY_ICON
	%PieceOptions.text = "%s%s" % [piece.display_name, dropdown_suffix] if piece != null else "SELECT BLOCK"
	%PieceOptions.icon = piece_icon
	%PieceOptions.tooltip_text = _piece_tooltip(piece) if piece != null else "Select a Block."
	%PieceOptions.disabled = piece_options.is_empty() or selection == null

func _populate_effect_options() -> void:
	effect_options.clear()
	var piece: PieceDefinition = selection.piece if selection != null else null
	var permanent_effect: PieceCardEffectDefinition = piece.permanent_card_effect if piece != null else null
	if permanent_effect != null:
		effect_options.append(permanent_effect)
		%EffectOptions.text = "%s%s" % [permanent_effect.display_name, permanent_suffix]
		%EffectOptions.icon = permanent_effect.icon if permanent_effect.icon != null else EMPTY_ICON
		%EffectOptions.tooltip_text = "%s\n\n%s\n\nThis Block's permanent effect cannot be changed." % [permanent_effect.display_name, permanent_effect.description]
		%EffectOptions.disabled = true
		return
	effect_options.append(null)
	for effect: PieceCardEffectDefinition in available_effects:
		if effect != null and (allow_incompatible_effects or effect.can_roll_for(piece)):
			effect_options.append(effect)
	if selection != null and selection.effect != null and (allow_incompatible_effects or selection.effect.can_roll_for(piece)) and not effect_options.has(selection.effect):
		effect_options.append(selection.effect)
	var selected_effect: PieceCardEffectDefinition = selection.effect if selection != null else null
	%EffectOptions.text = "%s%s" % [selected_effect.display_name, dropdown_suffix] if selected_effect != null else "%s%s" % [filler_title, dropdown_suffix]
	%EffectOptions.icon = selected_effect.icon if selected_effect != null and selected_effect.icon != null else EMPTY_ICON
	%EffectOptions.tooltip_text = selected_effect.description if selected_effect != null else filler_description
	%EffectOptions.disabled = piece == null or selection == null

func _normalize_effect() -> void:
	if selection == null or selection.piece == null:
		return
	if selection.piece.permanent_card_effect != null:
		selection.effect = null
	elif selection.effect != null and not allow_incompatible_effects and not selection.effect.can_roll_for(selection.piece):
		selection.effect = null

func _refresh_icons() -> void:
	var piece: PieceDefinition = selection.piece if selection != null else null
	%PieceIcon.texture = piece.upgrade_board_icon if piece != null and piece.upgrade_board_icon != null else EMPTY_ICON
	var effect: PieceCardEffectDefinition = piece.permanent_card_effect if piece != null and piece.permanent_card_effect != null else selection.effect if selection != null else null
	%EffectIcon.texture = effect.icon if effect != null and effect.icon != null else EMPTY_ICON

func _piece_tooltip(piece: PieceDefinition) -> String:
	var permanent_text: String = "\nPermanent effect: %s" % piece.permanent_card_effect.display_name if piece.permanent_card_effect != null else ""
	return "%s\n%d cells | %d rotations%s" % [piece.display_name, piece.base_cells.size(), PieceRotationService.get_unique_rotations(piece).size(), permanent_text]

func _piece_precedes(left: PieceDefinition, right: PieceDefinition) -> bool:
	if left == null:
		return false
	if right == null:
		return true
	var name_order: int = left.display_name.naturalnocasecmp_to(right.display_name)
	return left.resource_path < right.resource_path if name_order == 0 else name_order < 0

func _effect_precedes(left: PieceCardEffectDefinition, right: PieceCardEffectDefinition) -> bool:
	if left == null:
		return false
	if right == null:
		return true
	var name_order: int = left.display_name.naturalnocasecmp_to(right.display_name)
	return left.resource_path < right.resource_path if name_order == 0 else name_order < 0
