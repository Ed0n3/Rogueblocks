class_name UpgradeBoardShopCard
extends Button

signal piece_selected(piece: PieceDefinition)

var piece: PieceDefinition
var presentation: UpgradeMatrixPresentationConfiguration
var price: int = 0
var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()

func _ready() -> void:
	pressed.connect(_emit_piece_selected)

func setup(definition: PieceDefinition, fragment_price: int, owned_quantity: int, matrix_presentation: UpgradeMatrixPresentationConfiguration = null) -> void:
	piece = definition
	presentation = matrix_presentation if matrix_presentation != null else UpgradeMatrixConfiguration.load_default().presentation
	price = fragment_price
	%PieceName.text = piece.display_name
	%CellCount.text = "%d CELLS" % piece.base_cells.size()
	%Price.text = "%d FRAGMENTS" % price
	%Owned.text = "OWNED  %d" % owned_quantity
	tooltip_text = "%s\n%d cells\n%d Fragments\n%d owned" % [piece.display_name, piece.base_cells.size(), price, owned_quantity]
	queue_redraw()

func _emit_piece_selected() -> void:
	if piece != null:
		piece_selected.emit(piece)

func _draw() -> void:
	if piece == null:
		return
	var normalized_cells: Array[Vector2i] = PieceRotationService.normalize_cells(piece.base_cells)
	var fill_color: Color = Color(piece.preview_color, presentation.foundry_preview_fill_alpha)
	var outline_color: Color = piece.preview_color.lightened(presentation.foundry_outline_lighten_amount)
	PieceDrawing.draw_cells(self, normalized_cells, presentation.foundry_preview_rect, fill_color, outline_color)
	var border_color: Color = piece.preview_color if selected else Color(piece.preview_color, presentation.foundry_default_border_alpha)
	var border_width: float = presentation.foundry_selected_border_width if selected else presentation.foundry_default_border_width
	var border_rect: Rect2 = Rect2(Vector2.ONE * presentation.foundry_border_inset, size - Vector2.ONE * presentation.foundry_border_inset * 2.0)
	draw_rect(border_rect, border_color, false, border_width)
