class_name UpgradeBoardShopDialog
extends Control

signal piece_purchased(piece: PieceDefinition)

const SHOP_CARD_SCENE: PackedScene = preload("res://presentation/upgrade_board/upgrade_board_shop_card.tscn")
const SAVE_FAILURE_MESSAGE: String = "Purchase could not be saved. No Fragments were spent."

var shop_service: UpgradeBoardShopService
var configuration: UpgradeMatrixConfiguration
var catalog_items: Array[ShopItem] = []
var cards: Array[UpgradeBoardShopCard] = []
var selected_item: ShopItem
var selected_piece: PieceDefinition

func _ready() -> void:
	if shop_service == null:
		setup(UpgradeMatrixConfiguration.load_default())
	%Close.pressed.connect(close)
	%Buy.pressed.connect(_purchase_selected_piece)
	visibility_changed.connect(_handle_visibility_changed)

func setup(configuration: UpgradeMatrixConfiguration) -> void:
	self.configuration = configuration if configuration != null else UpgradeMatrixConfiguration.load_default()
	shop_service = UpgradeBoardShopService.new(self.configuration)

func open() -> void:
	visible = true
	_refresh_catalog()
	%Close.grab_focus()

func close() -> void:
	visible = false

func _refresh_catalog() -> void:
	for card: UpgradeBoardShopCard in cards:
		if is_instance_valid(card):
			card.queue_free()
	cards.clear()
	catalog_items = shop_service.generate_catalog(ContentRegistry.pieces, SaveService.profile).items
	for item: ShopItem in catalog_items:
		var piece: PieceDefinition = item.piece
		if piece == null:
			continue
		var card: UpgradeBoardShopCard = SHOP_CARD_SCENE.instantiate() as UpgradeBoardShopCard
		card.setup(piece, item.final_price, SaveService.profile.upgrade_piece_inventory.get_quantity(piece), configuration.presentation)
		card.piece_selected.connect(_select_piece)
		%Catalog.add_child(card)
		cards.append(card)
	%FragmentBalance.text = "%d FRAGMENTS" % SaveService.profile.fragments
	if selected_piece != null and _find_catalog_item(selected_piece) != null:
		_select_piece(selected_piece)
	elif not catalog_items.is_empty():
		_select_piece(catalog_items[0].piece)
	else:
		_clear_selection()

func _select_piece(piece: PieceDefinition) -> void:
	if piece == null:
		_clear_selection()
		return
	selected_piece = piece
	selected_item = _find_catalog_item(piece)
	for card: UpgradeBoardShopCard in cards:
		card.selected = card.piece == selected_piece
	%Preview.setup(shop_service.describe_item(selected_item, SaveService.profile))
	%PieceName.text = piece.display_name
	%PieceStats.text = "%d CELLS  •  %d UNIQUE ROTATION%s" % [piece.base_cells.size(), PieceRotationService.get_unique_rotations(piece).size(), "" if PieceRotationService.get_unique_rotations(piece).size() == 1 else "S"]
	%PieceDescription.text = "Place this Block entirely inside one Matrix area. Labyrinth walls, neutral gaps, area boundaries, and other Blocks cannot be crossed."
	%Owned.text = "OWNED  %d" % SaveService.profile.upgrade_piece_inventory.get_quantity(piece)
	%Price.text = "%d FRAGMENTS" % selected_item.final_price
	%Buy.tooltip_text = "Buy for %d Fragments" % selected_item.final_price
	%Buy.disabled = not shop_service.can_purchase_piece(piece, SaveService.profile)
	%Feedback.text = "Ready to add this Block to your reserve." if not %Buy.disabled else "Not enough Fragments."

func _find_catalog_item(piece: PieceDefinition) -> ShopItem:
	for item: ShopItem in catalog_items:
		if item.piece == piece:
			return item
	return null

func _clear_selection() -> void:
	selected_piece = null
	selected_item = null
	%PieceName.text = "NO BLOCK SELECTED"
	%PieceStats.text = ""
	%PieceDescription.text = "Select a Block from the catalog."
	%Owned.text = ""
	%Price.text = ""
	%Buy.tooltip_text = "Buy Block"
	%Buy.disabled = true
	%Feedback.text = ""

func _purchase_selected_piece() -> void:
	if selected_piece == null or not shop_service.can_purchase_piece(selected_piece, SaveService.profile):
		return
	var purchased_piece: PieceDefinition = selected_piece
	var previous_profile_data: Dictionary = SaveService.profile.to_save_data()
	if not shop_service.purchase_piece(selected_piece, SaveService.profile):
		_refresh_catalog()
		%Feedback.text = "This Block cannot be purchased right now."
		return
	if not SaveService.save_profile():
		SaveService.profile = ProfileState.from_save_data(previous_profile_data)
		_refresh_catalog()
		%Feedback.text = SAVE_FAILURE_MESSAGE
		return
	piece_purchased.emit(purchased_piece)
	_refresh_catalog()
	%Feedback.text = "%s added to the reserve." % selected_piece.display_name

func _handle_visibility_changed() -> void:
	if not visible:
		selected_item = null
		selected_piece = null

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
