class_name UpgradeBoardShopService
extends RefCounted

var economy: UpgradeMatrixEconomyConfiguration

func _init(matrix_configuration: UpgradeMatrixConfiguration = null) -> void:
	var active_configuration: UpgradeMatrixConfiguration = matrix_configuration if matrix_configuration != null else UpgradeMatrixConfiguration.load_default()
	economy = active_configuration.economy

func generate_shop(seed_value: int, seed_salt: int, pieces: Array[PieceDefinition], profile: ProfileState, discount: float = 0.0) -> ShopState:
	var state: ShopState = ShopState.new()
	if economy == null:
		return state
	var candidates: Array[PieceDefinition] = _unlocked_valid_pieces(pieces, profile)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value ^ seed_salt
	var offer_count: int = mini(economy.shop_offer_count, candidates.size())
	for index: int in offer_count:
		var selected_index: int = rng.randi_range(0, candidates.size() - 1)
		var piece: PieceDefinition = candidates.pop_at(selected_index)
		state.items.append(_create_piece_item(index, piece, discount))
	return state

func generate_catalog(pieces: Array[PieceDefinition], profile: ProfileState) -> ShopState:
	var state: ShopState = ShopState.new()
	var candidates: Array[PieceDefinition] = _unlocked_valid_pieces(pieces, profile)
	for index: int in candidates.size():
		state.items.append(_create_piece_item(index, candidates[index], 0.0))
	return state

func calculate_piece_price(piece: PieceDefinition, discount: float = 0.0) -> int:
	if piece == null or economy == null:
		return 0
	var applied_discount: float = clampf(discount, 0.0, economy.maximum_shop_discount)
	return _calculate_discounted_piece_price(piece, applied_discount)

func can_purchase(item: ShopItem, profile: ProfileState) -> bool:
	return describe_item(item, profile).can_purchase()

func describe_item(item: ShopItem, profile: ProfileState) -> ShopItemViewState:
	var view: ShopItemViewState = ShopItemViewState.new()
	view.item = item
	if item == null:
		view.availability = ShopItemViewState.Availability.UNAVAILABLE
		view.status_text = "Unavailable"
		return view
	_describe_board_piece(view, profile)
	if profile == null:
		view.availability = ShopItemViewState.Availability.UNAVAILABLE
		view.status_text = "Profile unavailable"
	elif item.purchased:
		view.availability = ShopItemViewState.Availability.PURCHASED
		view.status_text = "Bought"
	elif not view.restriction.is_empty():
		view.availability = ShopItemViewState.Availability.UNAVAILABLE
		view.status_text = view.restriction
	elif profile.fragments < item.final_price:
		view.availability = ShopItemViewState.Availability.UNAFFORDABLE
		view.status_text = "Need %d more Fragments" % (item.final_price - profile.fragments)
	else:
		view.availability = ShopItemViewState.Availability.AFFORDABLE
		view.status_text = "Affordable"
	return view

func purchase(item: ShopItem, profile: ProfileState) -> bool:
	if item == null or profile == null:
		return false
	if not can_purchase(item, profile):
		return false
	var piece: PieceDefinition = _piece_for_item(item)
	if piece == null:
		return false
	profile.fragments -= item.final_price
	profile.total_fragments_spent += item.final_price
	profile.upgrade_piece_inventory.add(piece, 1)
	item.purchased = true
	return true

func can_purchase_piece(piece: PieceDefinition, profile: ProfileState) -> bool:
	return is_piece_unlocked(piece, profile) and piece.is_valid() and ContentRegistry.pieces.has(piece) and profile.fragments >= calculate_piece_price(piece)

func is_piece_unlocked(piece: PieceDefinition, profile: ProfileState) -> bool:
	return piece != null and profile != null and (piece.initially_unlocked or profile.unlocked_pieces.has(piece))

func purchase_piece(piece: PieceDefinition, profile: ProfileState) -> bool:
	if not can_purchase_piece(piece, profile):
		return false
	var price: int = calculate_piece_price(piece)
	profile.fragments -= price
	profile.total_fragments_spent += price
	profile.upgrade_piece_inventory.add(piece, 1)
	return true

func _describe_board_piece(view: ShopItemViewState, profile: ProfileState) -> void:
	view.category = ShopItemViewState.Category.BOARD_PIECE
	view.category_name = "Upgrade Block"
	view.subtype_name = "Board piece"
	view.rarity_name = "Blueprint"
	view.piece = _piece_for_item(view.item)
	if view.item.type != ShopItem.ItemType.BOARD_PIECE:
		view.restriction = "Legacy offer"
		return
	if view.piece == null:
		view.restriction = "Unknown Block"
		return
	if not _has_valid_item_price(view.item, view.piece):
		view.restriction = "Invalid Block price"
		return
	if profile != null and not is_piece_unlocked(view.piece, profile):
		view.restriction = "Block not unlocked"
		return
	var cell_count: int = view.piece.base_cells.size()
	view.description = "Place this Block inside one upgrade area on the permanent 100 x 100 Upgrade Board."
	view.practical_effect = "Covers %d open area cell%s and advances that area's filled-cell requirement." % [cell_count, "" if cell_count == 1 else "s"]
	view.limitations = "The complete shape must remain inside one area and cannot overlap labyrinth walls or other Blocks."
	view.short_summary = "%d-cell Upgrade Board piece" % cell_count
	view.accent_color = view.piece.preview_color
	view.charge_count = 1

func _create_piece_item(index: int, piece: PieceDefinition, discount: float) -> ShopItem:
	var item: ShopItem = ShopItem.new()
	item.display_name = piece.display_name
	item.type = ShopItem.ItemType.BOARD_PIECE
	item.piece = piece
	item.base_price = calculate_piece_price(piece)
	item.final_price = calculate_piece_price(piece, discount)
	return item

func _unique_valid_pieces(pieces: Array[PieceDefinition]) -> Array[PieceDefinition]:
	var candidates: Array[PieceDefinition] = []
	var known_pieces: Array[PieceDefinition] = []
	for piece: PieceDefinition in pieces:
		if piece == null or not piece.is_valid() or known_pieces.has(piece):
			continue
		known_pieces.append(piece)
		candidates.append(piece)
	candidates.sort_custom(func(left: PieceDefinition, right: PieceDefinition) -> bool: return left.resource_path < right.resource_path)
	return candidates

func _unlocked_valid_pieces(pieces: Array[PieceDefinition], profile: ProfileState) -> Array[PieceDefinition]:
	var candidates: Array[PieceDefinition] = []
	for piece: PieceDefinition in _unique_valid_pieces(pieces):
		if is_piece_unlocked(piece, profile):
			candidates.append(piece)
	return candidates

func _calculate_base_piece_price(piece: PieceDefinition) -> int:
	var price: int = economy.first_cell_fragment_cost
	var additional_cell_count: int = maxi(0, piece.base_cells.size() - 1)
	for additional_cell_index: int in additional_cell_count:
		var additional_cell_cost: int = economy.additional_cell_start_fragment_cost - economy.additional_cell_fragment_cost_reduction * additional_cell_index
		price += maxi(economy.minimum_additional_cell_fragment_cost, additional_cell_cost)
	return price

func _calculate_discounted_piece_price(piece: PieceDefinition, discount: float) -> int:
	var base_price: int = _calculate_base_piece_price(piece)
	return maxi(economy.minimum_fragment_cost, floori(float(base_price) * (1.0 - discount)))

func _piece_for_item(item: ShopItem) -> PieceDefinition:
	if item == null:
		return null
	return item.piece

func _has_valid_item_price(item: ShopItem, piece: PieceDefinition) -> bool:
	if item == null or piece == null:
		return false
	if economy == null:
		return false
	var canonical_base_price: int = calculate_piece_price(piece)
	var minimum_discounted_price: int = calculate_piece_price(piece, economy.maximum_shop_discount)
	return item.base_price == canonical_base_price and item.final_price >= minimum_discounted_price and item.final_price <= canonical_base_price
