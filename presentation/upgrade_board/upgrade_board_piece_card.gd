class_name UpgradeBoardPieceCard
extends Button

signal piece_selected(piece: PieceDefinition)

var piece: PieceDefinition
var presentation: UpgradeMatrixPresentationConfiguration
var quantity: int = 0
var selected: bool = false:
	set(value):
		selected = value
		button_pressed = value
		queue_redraw()

func _ready() -> void:
	pressed.connect(_emit_selection)

func setup(definition: PieceDefinition, available_quantity: int, matrix_presentation: UpgradeMatrixPresentationConfiguration = null) -> void:
	piece = definition
	presentation = matrix_presentation if matrix_presentation != null else UpgradeMatrixConfiguration.load_default().presentation
	quantity = available_quantity
	%PieceName.text = piece.display_name
	%Quantity.text = "x%d" % quantity
	disabled = quantity <= 0
	tooltip_text = "%s\n%d available\n%d cells" % [piece.display_name, quantity, piece.base_cells.size()]
	queue_redraw()

func _emit_selection() -> void:
	if piece != null and quantity > 0:
		piece_selected.emit(piece)

func _draw() -> void:
	if piece == null:
		return
	var fill_alpha: float = presentation.reserve_available_fill_alpha if quantity > 0 else presentation.reserve_unavailable_fill_alpha
	var fill_color: Color = Color(piece.preview_color, fill_alpha)
	var preview_width: float = size.x - presentation.reserve_preview_horizontal_inset * 2.0
	var preview_rect: Rect2 = Rect2(presentation.reserve_preview_horizontal_inset, presentation.reserve_preview_top_offset, preview_width, presentation.reserve_preview_height)
	var normalized_cells: Array[Vector2i] = PieceRotationService.normalize_cells(piece.base_cells)
	var outline_color: Color = piece.preview_color.lightened(presentation.reserve_outline_lighten_amount)
	PieceDrawing.draw_cells(self, normalized_cells, preview_rect, fill_color, outline_color)
	var border_color: Color = Color(piece.preview_color, presentation.reserve_border_alpha)
	var border_rect: Rect2 = Rect2(Vector2.ONE * presentation.reserve_border_inset, size - Vector2.ONE * presentation.reserve_border_inset * 2.0)
	draw_rect(border_rect, border_color, false, presentation.reserve_border_width)
