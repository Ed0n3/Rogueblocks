extends Node

const BoardTileMapRenderer = preload("res://presentation/board/board_tile_map_renderer.gd")

const EXPECTED_BOARD_SIZE: Vector2i = Vector2i(100, 100)
const EXPECTED_BOARD_CELL_COUNT: int = 10000
const EXPECTED_UPGRADE_COUNT: int = 27
const MINIMUM_AREA_SIZE_SPREAD: int = 100
const DAMAGE_REFERENCE_CELL_COUNT: int = 200
const DAMAGE_LEVEL_ONE_REQUIREMENT: int = 15
const DAMAGE_LEVEL_TWO_REQUIREMENT: int = 50
const DAMAGE_LEVEL_THREE_REQUIREMENT: int = 110
const LARGE_PLACEMENT_COUNT: int = 3000
const VECTOR_TOLERANCE: float = 0.01
const CARDINAL_DIRECTIONS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const MONOMINO_PIECE: PieceDefinition = preload("res://content/pieces/monomino.tres")
const DOMINO_PIECE: PieceDefinition = preload("res://content/pieces/domino.tres")
const TRI_BLOCK_PIECE: PieceDefinition = preload("res://content/pieces/tri_i.tres")
const QUAD_BLOCK_PIECE: PieceDefinition = preload("res://content/pieces/tet_i.tres")
const PENTA_BLOCK_PIECE: PieceDefinition = preload("res://content/pieces/pent_l.tres")
const TRI_L_PIECE: PieceDefinition = preload("res://content/pieces/tri_l.tres")
const PENT_CROSS_PIECE: PieceDefinition = preload("res://content/pieces/pent_cross.tres")
const MONOMINO_FRAGMENT_COST: int = 4
const DOMINO_FRAGMENT_COST: int = 7
const TRI_BLOCK_FRAGMENT_COST: int = 9
const QUAD_BLOCK_FRAGMENT_COST: int = 11
const PENTA_BLOCK_FRAGMENT_COST: int = 13
const SIX_CELL_BLOCK_FRAGMENT_COST: int = 15
const DAMAGE_UPGRADE: UpgradeDefinition = preload("res://content/upgrades/damage_calibration.tres")
const CORE_UPGRADE: UpgradeDefinition = preload("res://content/upgrades/reinforced_core.tres")
const REDRAW_UPGRADE: UpgradeDefinition = preload("res://content/upgrades/second_look.tres")
const LARGER_SHOWCASE_UPGRADE: UpgradeDefinition = preload("res://content/upgrades/larger_showcase.tres")
const REWARD_INSIGHT_UPGRADE: UpgradeDefinition = preload("res://content/upgrades/reward_insight.tres")
const SHAPE_ARCHIVE_I_UPGRADE: UpgradeDefinition = preload("res://content/upgrades/shape_archive_i.tres")
const SHAPE_ARCHIVE_II_UPGRADE: UpgradeDefinition = preload("res://content/upgrades/shape_archive_ii.tres")

var checks: TestAssertions = TestAssertions.new()
var screenshot_path: String = ""
var foundry_screenshot_path: String = ""

func _ready() -> void:
	await get_tree().process_frame
	screenshot_path = _get_screenshot_path()
	foundry_screenshot_path = _get_foundry_screenshot_path()
	var original_profile: ProfileState = SaveService.profile
	SaveService.profile = ProfileState.new()
	var rules: UpgradeBoardRules = UpgradeBoardRules.load_default()
	var layout: UpgradeBoardLayout = UpgradeBoardLayoutService.new().generate(rules)
	var service: UpgradeBoardService = UpgradeBoardService.new(rules, layout)
	_test_centralized_configuration(rules, layout)
	_test_rules_and_regions(rules, layout)
	_test_themed_region_order(rules)
	_test_shop_pricing(rules, layout, service)
	_test_stable_region_mapping(rules, layout)
	_test_profile_round_trip()
	_test_profile_migration()
	_test_placement_validation(layout, service)
	_test_completed_area_validation(layout, service)
	_test_confirmed_state_repair(rules, layout, service)
	_test_staging_and_commit(layout, service)
	_test_large_state_commit(layout, service)
	_test_prerequisite_activation(layout, service)
	await _test_zoom_controls(rules, layout, service)
	await _test_upgrade_tree_layout()
	SaveService.profile = original_profile
	print("Upgrade Board tests: %d passed, %d failed" % [checks.passed, checks.failed])
	get_tree().quit(0 if checks.failed == 0 else 1)

func _test_centralized_configuration(configuration: UpgradeMatrixConfiguration, baseline_layout: UpgradeBoardLayout) -> void:
	checks.truthy(configuration.layout != null, "The Matrix preset exposes one typed layout section")
	checks.truthy(configuration.progression != null, "The Matrix preset exposes one typed progression section")
	checks.truthy(configuration.economy != null, "The Matrix preset exposes one typed economy section")
	checks.truthy(configuration.interaction != null, "The Matrix preset exposes one typed interaction section")
	checks.truthy(configuration.presentation != null, "The Matrix preset exposes one typed presentation section")
	checks.truthy(configuration.get_validation_errors().is_empty(), "The default Matrix preset passes section-level validation")
	for region_slot: UpgradeBoardRegionSlot in configuration.layout.region_slots:
		checks.truthy(region_slot.resource_path.begins_with("res://content/upgrade_matrix/regions/"), "Each authored Matrix region is independently configurable")
	var presentation_variant: UpgradeMatrixConfiguration = configuration.duplicate(true) as UpgradeMatrixConfiguration
	presentation_variant.interaction.cell_pixel_size *= 2.0
	presentation_variant.presentation.neutral_cell_color = Color.MAGENTA
	var presentation_variant_layout: UpgradeBoardLayout = UpgradeBoardLayoutService.new().generate(presentation_variant)
	checks.truthy(presentation_variant_layout.is_valid(), "Presentation and interaction variants preserve valid layout generation")
	for baseline_region: UpgradeBoardRegion in baseline_layout.regions:
		var variant_region: UpgradeBoardRegion = presentation_variant_layout.get_region(baseline_region.upgrade)
		checks.truthy(variant_region != null, "Configuration variants retain every authored upgrade region")
		if variant_region != null:
			checks.equal(variant_region.area_cells, baseline_region.area_cells, "Presentation and interaction settings do not affect generated region cells")
	var invalid_zoom_configuration: UpgradeMatrixConfiguration = configuration.duplicate(true) as UpgradeMatrixConfiguration
	invalid_zoom_configuration.interaction.minimum_zoom = invalid_zoom_configuration.interaction.maximum_zoom + 1.0
	checks.truthy(not invalid_zoom_configuration.get_validation_errors().is_empty(), "Invalid cross-field Matrix settings are rejected before generation")

func _test_rules_and_regions(rules: UpgradeBoardRules, layout: UpgradeBoardLayout) -> void:
	checks.equal(rules.board_size, EXPECTED_BOARD_SIZE, "Upgrade Board rules define a 100x100 board")
	checks.equal(rules.layout_version, UpgradeBoardRules.load_default().layout_version, "Upgrade Board rules use the current irregular-area layout version")
	checks.equal(layout.board_size, EXPECTED_BOARD_SIZE, "Generated Upgrade Board uses the configured dimensions")
	checks.truthy(layout.is_valid(), "Authored Upgrade Board region mapping is valid")
	checks.equal(ContentRegistry.upgrades.size(), EXPECTED_UPGRADE_COUNT, "All current upgrades are registered")
	checks.equal(rules.region_slots.size(), EXPECTED_UPGRADE_COUNT, "Authored Upgrade Board mapping contains every current region slot")
	checks.equal(layout.regions.size(), EXPECTED_UPGRADE_COUNT, "Every current upgrade receives one region")
	for region_slot: UpgradeBoardRegionSlot in rules.region_slots:
		checks.truthy(region_slot != null and region_slot.upgrade != null, "Every Matrix slot references an Upgrade resource directly")
		if region_slot != null and region_slot.upgrade != null:
			checks.truthy(ContentRegistry.upgrades.has(region_slot.upgrade), "Matrix slot reuses its registered Upgrade resource: %s" % region_slot.upgrade.display_name)
	var mapped_counts: Dictionary[UpgradeDefinition, int] = {}
	var claimed_cells: Dictionary[Vector2i, bool] = {}
	var authored_area_sizes: Dictionary[int, bool] = {}
	var total_wall_count: int = 0
	var wall_free_region_count: int = 0
	var irregular_region_count: int = 0
	var smallest_area_size: int = EXPECTED_BOARD_CELL_COUNT
	var largest_area_size: int = 0
	for region: UpgradeBoardRegion in layout.regions:
		checks.truthy(region != null and region.upgrade != null, "Every authored area has a registered upgrade")
		if region == null or region.upgrade == null:
			continue
		checks.truthy(not region.area_cells.is_empty(), "Upgrade area contains authored cells: %s" % region.upgrade.display_name)
		checks.equal(region.usable_cells.size() + region.wall_cells.size(), region.area_cells.size(), "Area cells are partitioned into open cells and internal walls: %s" % region.upgrade.display_name)
		checks.falsy(authored_area_sizes.has(region.area_cells.size()), "Every upgrade area has a different authored size: %s" % region.upgrade.display_name)
		authored_area_sizes[region.area_cells.size()] = true
		smallest_area_size = mini(smallest_area_size, region.area_cells.size())
		largest_area_size = maxi(largest_area_size, region.area_cells.size())
		checks.truthy(_cells_are_connected(region.area_cells), "Upgrade area is one connected shape: %s" % region.upgrade.display_name)
		if region.area_cells.size() < region.bounds.size.x * region.bounds.size.y:
			irregular_region_count += 1
		if region.wall_cells.is_empty():
			wall_free_region_count += 1
		total_wall_count += region.wall_cells.size()
		for cell: Vector2i in region.area_cells:
			checks.truthy(layout.is_within_bounds(cell), "Area cell stays inside the single 100x100 board: %s" % region.upgrade.display_name)
			checks.falsy(claimed_cells.has(cell), "Upgrade areas do not overlap: %s" % cell)
			claimed_cells[cell] = true
			checks.equal(layout.get_region_at(cell), region, "Area lookup returns its owning upgrade: %s" % cell)
			checks.truthy(region.has_area_cell(cell), "Area lookup contains every authored cell: %s" % cell)
		for wall_cell: Vector2i in region.wall_cells:
			checks.truthy(region.has_area_cell(wall_cell), "Labyrinth wall remains inside its upgrade area: %s" % wall_cell)
			checks.truthy(region.has_wall_cell(wall_cell), "Area exposes each authored labyrinth wall: %s" % wall_cell)
			checks.truthy(layout.is_wall(wall_cell), "Board exposes each authored labyrinth wall: %s" % wall_cell)
			checks.falsy(region.has_usable_cell(wall_cell), "Labyrinth wall is not placeable area space: %s" % wall_cell)
			for direction: Vector2i in CARDINAL_DIRECTIONS:
				checks.truthy(region.has_area_cell(wall_cell + direction), "Labyrinth wall is strictly internal to its area: %s" % wall_cell)
		for usable_cell: Vector2i in region.usable_cells:
			checks.truthy(region.has_area_cell(usable_cell), "Open area cell remains inside its upgrade area: %s" % usable_cell)
			checks.falsy(layout.is_wall(usable_cell), "Open area cell does not overlap a labyrinth wall: %s" % usable_cell)
		var thresholds: PackedInt32Array = region.get_thresholds(rules)
		checks.equal(thresholds.size(), region.upgrade.max_level, "Area exposes one scaled threshold per upgrade level: %s" % region.upgrade.display_name)
		var previous_threshold: int = 0
		for threshold: int in thresholds:
			checks.truthy(threshold > previous_threshold, "Scaled area thresholds remain strictly increasing: %s" % region.upgrade.display_name)
			checks.truthy(threshold <= region.usable_cells.size(), "Scaled area thresholds fit its usable capacity: %s" % region.upgrade.display_name)
			previous_threshold = threshold
		if region.upgrade.final_level_requires_full_area:
			checks.equal(thresholds[thresholds.size() - 1], region.usable_cells.size(), "The final upgrade level requires 100 percent of its usable area: %s" % region.upgrade.display_name)
		else:
			checks.truthy(thresholds[thresholds.size() - 1] < region.usable_cells.size(), "Configured single-level upgrades retain their authored partial-area threshold: %s" % region.upgrade.display_name)
		mapped_counts[region.upgrade] = int(mapped_counts.get(region.upgrade, 0)) + 1
	checks.equal(authored_area_sizes.size(), EXPECTED_UPGRADE_COUNT, "All current upgrade areas use different cell counts")
	checks.truthy(largest_area_size - smallest_area_size >= MINIMUM_AREA_SIZE_SPREAD, "Authored upgrade areas have a materially varied size range")
	checks.equal(irregular_region_count, EXPECTED_UPGRADE_COUNT, "Every upgrade area has a non-rectangular silhouette")
	checks.truthy(total_wall_count > 0, "The single board contains internal labyrinth walls")
	checks.truthy(wall_free_region_count > 0 and wall_free_region_count < EXPECTED_UPGRADE_COUNT, "Only selected upgrade areas contain labyrinth walls")
	for upgrade: UpgradeDefinition in ContentRegistry.upgrades:
		checks.equal(int(mapped_counts.get(upgrade, 0)), 1, "Upgrade is mapped exactly once: %s" % upgrade.display_name)
	var neutral_cell_count: int = 0
	for y: int in EXPECTED_BOARD_SIZE.y:
		for x: int in EXPECTED_BOARD_SIZE.x:
			var board_cell: Vector2i = Vector2i(x, y)
			if layout.get_region_at(board_cell) == null:
				neutral_cell_count += 1
				checks.falsy(layout.is_wall(board_cell), "Neutral board gaps are distinct from labyrinth walls: %s" % board_cell)
				checks.falsy(layout.is_placeable(board_cell), "Neutral board gaps reject Block placement: %s" % board_cell)
	checks.equal(claimed_cells.size() + neutral_cell_count, EXPECTED_BOARD_CELL_COUNT, "Upgrade areas and neutral cells cover the single 100x100 board")
	checks.truthy(neutral_cell_count > 0, "The board retains neutral space between irregular upgrade areas")
	var damage_region: UpgradeBoardRegion = layout.get_region(DAMAGE_UPGRADE)
	var damage_thresholds: PackedInt32Array = damage_region.get_thresholds(rules)
	checks.equal(damage_region.usable_cells.size(), DAMAGE_REFERENCE_CELL_COUNT, "Line Impact retains its 200-cell reference capacity")
	checks.truthy(damage_thresholds.size() >= 3, "Line Impact exposes at least three board thresholds")
	checks.equal(damage_thresholds[0], DAMAGE_LEVEL_ONE_REQUIREMENT, "Line Impact level one requires 15 cells")
	checks.equal(damage_thresholds[1], DAMAGE_LEVEL_TWO_REQUIREMENT, "Line Impact level two requires 50 cells")
	checks.equal(damage_thresholds[2], DAMAGE_LEVEL_THREE_REQUIREMENT, "Line Impact level three requires 110 cells")
	checks.equal(damage_thresholds[damage_thresholds.size() - 1], damage_region.usable_cells.size(), "Line Impact's final level consumes its full 200-cell area")
	checks.equal(REDRAW_UPGRADE.max_level, 4, "Redraw Reserve consolidates redraw progression into four levels")
	checks.equal(LARGER_SHOWCASE_UPGRADE.max_level, 1, "Wider Draft has one level")
	checks.equal(REWARD_INSIGHT_UPGRADE.max_level, 1, "Reward Reroll has one level")
	checks.equal(layout.get_region(LARGER_SHOWCASE_UPGRADE).area_cells.size(), 140, "Wider Draft owns its authored 140-cell Matrix area")
	checks.equal(layout.get_region(LARGER_SHOWCASE_UPGRADE).get_thresholds(rules)[0], 104, "Wider Draft requires all 104 usable cells")
	checks.equal(layout.get_region(REWARD_INSIGHT_UPGRADE).get_thresholds(rules)[0], 14, "Reward Reroll preserves its former first-level Matrix requirement")
	var core_thresholds: PackedInt32Array = layout.get_region(CORE_UPGRADE).get_thresholds(rules)
	var previous_threshold: int = 0
	var previous_level_cost: int = 0
	for threshold: int in core_thresholds:
		var level_cost: int = threshold - previous_threshold
		checks.truthy(level_cost > previous_level_cost, "Core Plating board levels become progressively more expensive")
		previous_threshold = threshold
		previous_level_cost = level_cost

func _test_themed_region_order(rules: UpgradeBoardRules) -> void:
	var themed_upgrade_order: Array[UpgradeDefinition] = [
		preload("res://content/upgrades/shape_archive_i.tres"),
		preload("res://content/upgrades/shape_archive_ii.tres"),
		preload("res://content/upgrades/shape_archive_iii.tres"),
		preload("res://content/upgrades/shape_archive_iv.tres"),
		preload("res://content/upgrades/shape_archive_v.tres"),
		preload("res://content/upgrades/shape_archive_vi.tres"),
		preload("res://content/upgrades/second_look.tres"),
		preload("res://content/upgrades/expanded_selection.tres"),
		preload("res://content/upgrades/larger_showcase.tres"),
		preload("res://content/upgrades/curators_seal.tres"),
		preload("res://content/upgrades/shape_archive_vii.tres"),
		preload("res://content/upgrades/reward_insight.tres"),
		preload("res://content/upgrades/starter_cache.tres"),
		preload("res://content/upgrades/negotiator.tres"),
		preload("res://content/upgrades/salvager.tres"),
		preload("res://content/upgrades/expanded_belt.tres"),
		preload("res://content/upgrades/deep_pockets.tres"),
		preload("res://content/upgrades/reinforced_core.tres"),
		preload("res://content/upgrades/emergency_clearance.tres"),
		preload("res://content/upgrades/last_reserve.tres"),
		preload("res://content/upgrades/field_repair.tres"),
		preload("res://content/upgrades/damage_calibration.tres"),
		preload("res://content/upgrades/prepared_adventurer.tres"),
		preload("res://content/upgrades/relic_archive_i.tres"),
		preload("res://content/upgrades/encounter_archive_i.tres"),
		preload("res://content/upgrades/advanced_routes.tres"),
		preload("res://content/upgrades/spawn_more_elites.tres"),
	]
	for expected_slot_index: int in themed_upgrade_order.size():
		var expected_upgrade: UpgradeDefinition = themed_upgrade_order[expected_slot_index]
		var region_slot: UpgradeBoardRegionSlot = _find_region_slot(rules, expected_upgrade)
		checks.truthy(region_slot != null, "The themed Matrix layout contains %s" % expected_upgrade.display_name)
		if region_slot != null:
			checks.equal(region_slot.slot_index, expected_slot_index, "%s occupies its themed Matrix position" % expected_upgrade.display_name)
	checks.truthy(_find_region_slot_at(rules, 27) == null, "The first spare Matrix region remains empty")
	checks.truthy(_find_region_slot_at(rules, 28) == null, "The second spare Matrix region remains empty")
	checks.truthy(_find_region_slot_at(rules, 29) == null, "The third spare Matrix region remains empty")

func _test_shop_pricing(rules: UpgradeBoardRules, layout: UpgradeBoardLayout, board_service: UpgradeBoardService) -> void:
	var shop_service: UpgradeBoardShopService = UpgradeBoardShopService.new()
	var custom_configuration: UpgradeMatrixConfiguration = rules.duplicate(true) as UpgradeMatrixConfiguration
	custom_configuration.economy.first_cell_fragment_cost = MONOMINO_FRAGMENT_COST + 5
	var custom_shop_service: UpgradeBoardShopService = UpgradeBoardShopService.new(custom_configuration)
	checks.equal(custom_shop_service.calculate_piece_price(MONOMINO_PIECE), MONOMINO_FRAGMENT_COST + 5, "The Matrix shop uses its injected economy configuration")
	checks.equal(shop_service.calculate_piece_price(MONOMINO_PIECE), MONOMINO_FRAGMENT_COST, "A custom Matrix economy does not mutate the default preset")
	var catalog_profile: ProfileState = ProfileState.new()
	var base_prices_by_cell_count: Dictionary[int, int] = {}
	var discounted_prices_by_cell_count: Dictionary[int, int] = {}
	var locked_piece: PieceDefinition
	var initially_unlocked_piece_count: int = 0
	for piece: PieceDefinition in ContentRegistry.pieces:
		var base_price: int = shop_service.calculate_piece_price(piece)
		var discounted_price: int = shop_service.calculate_piece_price(piece, rules.maximum_shop_discount)
		var cell_count: int = piece.base_cells.size()
		if base_prices_by_cell_count.has(cell_count):
			checks.equal(base_price, base_prices_by_cell_count[cell_count], "Blocks with %d cells share one base Fragment price: %s" % [cell_count, piece.display_name])
			checks.equal(discounted_price, discounted_prices_by_cell_count[cell_count], "Blocks with %d cells share one discounted Fragment price: %s" % [cell_count, piece.display_name])
		else:
			base_prices_by_cell_count[cell_count] = base_price
			discounted_prices_by_cell_count[cell_count] = discounted_price
		if piece.initially_unlocked:
			initially_unlocked_piece_count += 1
		elif locked_piece == null:
			locked_piece = piece
	checks.equal(shop_service.calculate_piece_price(MONOMINO_PIECE), MONOMINO_FRAGMENT_COST, "A Monoblock costs four Fragments")
	checks.equal(shop_service.calculate_piece_price(DOMINO_PIECE), DOMINO_FRAGMENT_COST, "A Duoblock costs seven Fragments")
	checks.equal(shop_service.calculate_piece_price(TRI_BLOCK_PIECE), TRI_BLOCK_FRAGMENT_COST, "A three-cell Block costs nine Fragments")
	checks.equal(shop_service.calculate_piece_price(QUAD_BLOCK_PIECE), QUAD_BLOCK_FRAGMENT_COST, "A four-cell Block costs eleven Fragments")
	checks.equal(shop_service.calculate_piece_price(PENTA_BLOCK_PIECE), PENTA_BLOCK_FRAGMENT_COST, "A five-cell Block costs thirteen Fragments")
	var six_cell_piece: PieceDefinition = PieceDefinition.new()
	for cell_index: int in 6:
		six_cell_piece.base_cells.append(Vector2i(cell_index, 0))
	checks.equal(shop_service.calculate_piece_price(six_cell_piece), SIX_CELL_BLOCK_FRAGMENT_COST, "A six-cell Block costs fifteen Fragments")
	checks.equal(DOMINO_FRAGMENT_COST - MONOMINO_FRAGMENT_COST, 3, "The second Block cell costs three Fragments")
	checks.equal(TRI_BLOCK_FRAGMENT_COST - DOMINO_FRAGMENT_COST, 2, "The third Block cell costs two Fragments")
	checks.equal(QUAD_BLOCK_FRAGMENT_COST - TRI_BLOCK_FRAGMENT_COST, 2, "The fourth Block cell costs two Fragments")
	checks.equal(PENTA_BLOCK_FRAGMENT_COST - QUAD_BLOCK_FRAGMENT_COST, 2, "The fifth Block cell costs two Fragments")
	checks.equal(SIX_CELL_BLOCK_FRAGMENT_COST - PENTA_BLOCK_FRAGMENT_COST, 2, "Additional Block cells never cost fewer than two Fragments")
	var shop: ShopState = shop_service.generate_shop(7319, 101, ContentRegistry.pieces, catalog_profile, rules.maximum_shop_discount)
	var catalog: ShopState = shop_service.generate_catalog(ContentRegistry.pieces, catalog_profile)
	checks.truthy(shop.has_only_board_pieces(), "The compatibility Fragment offer contains only Upgrade Board Blocks")
	checks.equal(catalog.items.size(), initially_unlocked_piece_count, "The Matrix foundry catalog lists only initially unlocked Block shapes")
	checks.truthy(catalog.has_only_board_pieces(), "The Matrix foundry catalog contains only Upgrade Board Blocks")
	checks.truthy(locked_piece != null, "The registered Block collection includes progression-locked shapes")
	if locked_piece != null:
		checks.truthy(_find_shop_item(catalog, locked_piece) == null, "A locked Block is absent from the Matrix foundry catalog")
		var locked_profile: ProfileState = ProfileState.new()
		locked_profile.fragments = shop_service.calculate_piece_price(locked_piece)
		checks.falsy(shop_service.can_purchase_piece(locked_piece, locked_profile), "A locked Block is not purchasable with sufficient Fragments")
		checks.falsy(shop_service.purchase_piece(locked_piece, locked_profile), "Direct purchase cannot bypass a Block unlock")
		checks.equal(locked_profile.upgrade_piece_inventory.get_quantity(locked_piece), 0, "A rejected locked-Block purchase grants no reserve piece")
		catalog_profile.unlocked_pieces.append(locked_piece)
		var expanded_catalog: ShopState = shop_service.generate_catalog(ContentRegistry.pieces, catalog_profile)
		var unlocked_item: ShopItem = _find_shop_item(expanded_catalog, locked_piece)
		checks.equal(expanded_catalog.items.size(), initially_unlocked_piece_count + 1, "A permanently unlocked Block appears in the Matrix foundry catalog")
		checks.truthy(unlocked_item != null, "The unlocked catalog exposes the newly available Block")
		if unlocked_item != null:
			checks.falsy(shop_service.purchase(unlocked_item, locked_profile), "A catalog item still validates the purchasing profile's Block unlock")
	checks.equal(shop_service.calculate_piece_price(ContentRegistry.pieces[0], 1.0), shop_service.calculate_piece_price(ContentRegistry.pieces[0], rules.maximum_shop_discount), "Block discounts respect the configured maximum")
	checks.truthy(not shop.items.is_empty(), "The Matrix Fragment service generates purchasable Upgrade Board Blocks")
	if shop.items.is_empty():
		return
	var item: ShopItem = shop.items[0]
	var offered_piece: PieceDefinition = item.piece
	var unaffordable_profile: ProfileState = ProfileState.new()
	unaffordable_profile.fragments = item.final_price - 1
	checks.falsy(shop_service.purchase(item, unaffordable_profile), "A player cannot receive a board Block without enough Fragments")
	checks.equal(unaffordable_profile.upgrade_piece_inventory.get_total_quantity(), 0, "A rejected Fragment purchase leaves the board reserve empty")
	var purchased_item: ShopItem = ShopItem.from_save_data(item.to_save_data())
	purchased_item.purchased = false
	var purchase_profile: ProfileState = ProfileState.new()
	var remaining_fragments: int = 7
	purchase_profile.fragments = purchased_item.final_price + remaining_fragments
	checks.truthy(shop_service.purchase(purchased_item, purchase_profile), "Spending enough Fragments buys the offered board Block")
	checks.equal(purchase_profile.fragments, remaining_fragments, "Buying a board Block deducts its exact Fragment price")
	checks.equal(purchase_profile.total_fragments_spent, purchased_item.final_price, "Buying a board Block records the spent Fragments")
	checks.equal(purchase_profile.upgrade_piece_inventory.get_quantity(offered_piece), 1, "A bought board Block enters the persistent placement reserve")
	checks.falsy(shop_service.purchase(purchased_item, purchase_profile), "A purchased catalog item cannot be bought twice")
	checks.equal(purchase_profile.fragments, remaining_fragments, "A repeated purchase attempt spends no additional Fragments")
	checks.equal(purchase_profile.upgrade_piece_inventory.get_quantity(offered_piece), 1, "A repeated purchase attempt grants no duplicate piece")
	var repeat_purchase_profile: ProfileState = ProfileState.new()
	var repeat_purchase_price: int = shop_service.calculate_piece_price(offered_piece)
	repeat_purchase_profile.fragments = repeat_purchase_price * 2
	checks.truthy(shop_service.purchase_piece(offered_piece, repeat_purchase_profile), "A Matrix catalog Block can be purchased directly")
	checks.truthy(shop_service.purchase_piece(offered_piece, repeat_purchase_profile), "A Matrix catalog Block can be purchased repeatedly")
	checks.equal(repeat_purchase_profile.upgrade_piece_inventory.get_quantity(offered_piece), 2, "Repeated Matrix purchases add one reserve Block each")
	checks.equal(repeat_purchase_profile.fragments, 0, "Repeated Matrix purchases deduct each exact Fragment price")
	var malformed_item: ShopItem = ShopItem.from_save_data(item.to_save_data())
	malformed_item.purchased = false
	malformed_item.final_price = -1
	var malformed_profile: ProfileState = ProfileState.new()
	var malformed_fragments_before: int = malformed_profile.fragments
	checks.falsy(shop_service.purchase(malformed_item, malformed_profile), "A malformed compatibility offer cannot grant a Block")
	checks.equal(malformed_profile.fragments, malformed_fragments_before, "A malformed compatibility offer cannot add Fragments")
	checks.equal(malformed_profile.upgrade_piece_inventory.get_total_quantity(), 0, "A malformed compatibility offer cannot add reserve Blocks")
	var restored_purchase_profile: ProfileState = ProfileState.from_save_data(purchase_profile.to_save_data())
	checks.equal(restored_purchase_profile.upgrade_piece_inventory.get_quantity(offered_piece), 1, "A bought board Block survives profile serialization")
	var purchased_placement: UpgradeBoardPlacement = _find_valid_placement(board_service, offered_piece, 0, restored_purchase_profile.upgrade_board_state, restored_purchase_profile.upgrade_board_legacy_progress, 101)
	checks.truthy(purchased_placement != null, "A shop-bought Block can be positioned on the single board")
	if purchased_placement == null:
		return
	var purchased_state: UpgradeBoardState = restored_purchase_profile.upgrade_board_state.duplicate_state()
	var purchased_inventory: UpgradePieceInventory = restored_purchase_profile.upgrade_piece_inventory.duplicate_inventory()
	checks.truthy(purchased_inventory.consume(offered_piece, 1), "Staging consumes the shop-bought Block from the working reserve")
	purchased_state.add_placement(purchased_placement)
	var purchase_commit: UpgradeBoardCommitResult = board_service.commit(restored_purchase_profile, purchased_state, purchased_inventory)
	checks.truthy(purchase_commit.success, "A shop-bought Block commits to the permanent board")
	checks.equal(restored_purchase_profile.upgrade_piece_inventory.get_quantity(offered_piece), 0, "A committed shop-bought Block leaves the reserve")
	checks.equal(restored_purchase_profile.upgrade_board_state.placements.size(), 1, "A committed shop-bought Block enters the confirmed board state")
	var committed_purchase_profile: ProfileState = ProfileState.from_save_data(restored_purchase_profile.to_save_data())
	checks.equal(committed_purchase_profile.upgrade_board_state.placements.size(), 1, "A committed shop-bought Block survives profile serialization")
	checks.equal(committed_purchase_profile.upgrade_board_state.placements[0].piece, offered_piece, "The serialized confirmed Block retains the purchased shape")

func _test_stable_region_mapping(rules: UpgradeBoardRules, baseline_layout: UpgradeBoardLayout) -> void:
	var reordered_rules: UpgradeBoardRules = rules.duplicate(true) as UpgradeBoardRules
	reordered_rules.region_slots.reverse()
	var shuffled_layout: UpgradeBoardLayout = UpgradeBoardLayoutService.new().generate(reordered_rules)
	checks.truthy(shuffled_layout.is_valid(), "Reordered resource slots preserve a valid authored region mapping")
	checks.equal(shuffled_layout.regions.size(), baseline_layout.regions.size(), "Reordered resource slots map every current upgrade")
	for upgrade: UpgradeDefinition in ContentRegistry.upgrades:
		var baseline_region: UpgradeBoardRegion = baseline_layout.get_region(upgrade)
		var shuffled_region: UpgradeBoardRegion = shuffled_layout.get_region(upgrade)
		checks.truthy(baseline_region != null and shuffled_region != null, "Stable mapping contains upgrade in both layouts: %s" % upgrade.display_name)
		if baseline_region != null and shuffled_region != null:
			checks.equal(shuffled_region.bounds, baseline_region.bounds, "Shuffled input preserves region bounds: %s" % upgrade.display_name)
			checks.equal(shuffled_region.area_cells, baseline_region.area_cells, "Shuffled input preserves irregular area cells: %s" % upgrade.display_name)
			checks.equal(shuffled_region.wall_cells, baseline_region.wall_cells, "Shuffled input preserves internal labyrinth walls: %s" % upgrade.display_name)
			checks.equal(shuffled_region.usable_cells, baseline_region.usable_cells, "Shuffled input preserves open area cells: %s" % upgrade.display_name)
			checks.equal(shuffled_region.label_cell, baseline_region.label_cell, "Shuffled input preserves area label placement: %s" % upgrade.display_name)
	for region_index: int in baseline_layout.regions.size():
		checks.equal(shuffled_layout.regions[region_index].upgrade, baseline_layout.regions[region_index].upgrade, "Reordered resource slots preserve authored region order: %d" % region_index)

func _test_profile_round_trip() -> void:
	var source: ProfileState = ProfileState.new()
	source.fragments = 73
	source.upgrade_piece_inventory.add(TRI_L_PIECE, 2)
	source.upgrade_board_state.add_placement(UpgradeBoardPlacement.new(TRI_L_PIECE, Vector2i(4, 7), 1, 201))
	source.upgrade_board_legacy_progress.append(UpgradeLevelState.new(DAMAGE_UPGRADE, 2))
	var restored: ProfileState = ProfileState.from_save_data(source.to_save_data())
	checks.equal(restored.upgrade_piece_inventory.get_quantity(TRI_L_PIECE), 2, "Upgrade piece inventory survives profile serialization")
	checks.equal(restored.upgrade_board_state.placements.size(), 1, "Upgrade Board placements survive profile serialization")
	checks.equal(restored.upgrade_board_state.layout_version, source.upgrade_board_state.layout_version, "Upgrade Board layout version survives profile serialization")
	var restored_placement: UpgradeBoardPlacement = restored.upgrade_board_state.placements[0]
	checks.equal(restored_placement.piece, TRI_L_PIECE, "Serialized Upgrade Board placement retains its piece resource")
	checks.equal(restored_placement.origin, Vector2i(4, 7), "Serialized Upgrade Board placement retains its origin")
	checks.equal(restored_placement.rotation_index, 1, "Serialized Upgrade Board placement retains its rotation")
	checks.equal(restored.upgrade_board_legacy_progress[0].level, 2, "Legacy Upgrade Board levels survive profile serialization")

func _test_profile_migration() -> void:
	var version_six: Dictionary = {
		"version": 6,
		"purchased_upgrade_levels": {"upgrade_damage_calibration": 2},
		"unknown_future_field": "preserved",
	}
	var migrated: Dictionary = SaveMigrationService.new().migrate_profile(version_six)
	checks.equal(int(migrated.get("version", 0)), ProfileState.CURRENT_VERSION, "Profile migration advances version six to the current version")
	checks.equal(String(migrated.get("unknown_future_field", "")), "preserved", "Profile migration preserves unknown fields")
	var migrated_profile: ProfileState = ProfileState.from_save_data(migrated)
	checks.equal(migrated_profile.upgrade_board_legacy_progress[0].level, 2, "Profile migration preserves purchased upgrades as a board legacy floor")
	checks.equal(migrated_profile.upgrade_piece_inventory.get_total_quantity(), 0, "Profile migration initializes an empty Upgrade Board reserve")
	checks.equal(migrated_profile.upgrade_board_state.placements.size(), 0, "Profile migration initializes an empty Upgrade Board state")
	checks.equal(migrated_profile.upgrade_board_state.layout_version, UpgradeBoardRules.load_default().layout_version, "Profile migration initializes an empty board at the current layout version")
	var version_eight: Dictionary = {
		"version": 8,
		"upgrade_progress": [
			{"upgrade": ProfileMigration8To9.REDRAW_UID, "level": 3},
			{"upgrade": ProfileMigration8To9.CONTROLLED_REDRAW_UID, "level": 2},
			{"upgrade": ProfileMigration8To9.EXPANDED_FOUNDATION_UID, "level": 1},
		],
		"upgrade_board_legacy_progress": [
			{"upgrade": ProfileMigration8To9.REDRAW_UID, "level": 1},
			{"upgrade": ProfileMigration8To9.CONTROLLED_REDRAW_UID, "level": 1},
			{"upgrade": ProfileMigration8To9.EXPANDED_FOUNDATION_UID, "level": 1},
		],
	}
	var consolidated: Dictionary = ProfileMigration8To9.new().migrate(version_eight)
	var consolidated_profile: ProfileState = ProfileState.from_save_data(consolidated)
	checks.equal(consolidated_profile.get_upgrade_level(REDRAW_UPGRADE), REDRAW_UPGRADE.max_level, "Redraw migration combines both former upgrade levels and clamps them to the new maximum")
	checks.equal(consolidated_profile.upgrade_progress.size(), 1, "Redraw migration removes Expanded Foundation from purchased progression")
	checks.equal(consolidated_profile.upgrade_board_legacy_progress.size(), 1, "Redraw migration removes Expanded Foundation from board progression")
	checks.equal(consolidated_profile.upgrade_board_legacy_progress[0].level, 2, "Redraw migration combines both former board progression levels")

func _test_placement_validation(layout: UpgradeBoardLayout, service: UpgradeBoardService) -> void:
	_test_hollow_origin_primary_selection(service.rules)
	var empty_state: UpgradeBoardState = UpgradeBoardState.new()
	var legacy_levels: Array[UpgradeLevelState] = []
	var neutral_cell: Vector2i = _find_neutral_cell(layout)
	checks.truthy(neutral_cell.x >= 0, "The single board exposes neutral gaps between upgrade areas")
	checks.falsy(layout.is_placeable(neutral_cell), "Neutral gaps are not placement cells")
	var neutral_placement: UpgradeBoardPlacement = UpgradeBoardPlacement.new(MONOMINO_PIECE, neutral_cell, 0, 301)
	var neutral_result: UpgradeBoardPlacementResult = service.validate_placement(empty_state, neutral_placement, legacy_levels)
	checks.equal(neutral_result.failure, UpgradeBoardPlacementResult.Failure.OUTSIDE_AREA, "Placement validation rejects a Block in neutral space")
	var area_boundary_placement: UpgradeBoardPlacement = _find_spanning_placement(layout, 1, 1, true, 302)
	checks.truthy(area_boundary_placement != null, "The authored board exposes a shape that geometrically crosses an area into neutral space")
	if area_boundary_placement != null:
		var area_boundary_result: UpgradeBoardPlacementResult = service.validate_placement(empty_state, area_boundary_placement, legacy_levels)
		checks.equal(area_boundary_result.failure, UpgradeBoardPlacementResult.Failure.OUTSIDE_AREA, "A Block cannot cross an upgrade-area boundary into neutral space")
	var cross_area_placement: UpgradeBoardPlacement = _find_spanning_placement(layout, 2, EXPECTED_UPGRADE_COUNT, true, 303)
	checks.truthy(cross_area_placement != null, "The authored board exposes a shape that geometrically touches multiple areas")
	if cross_area_placement != null:
		var cross_area_result: UpgradeBoardPlacementResult = service.validate_placement(empty_state, cross_area_placement, legacy_levels)
		checks.equal(cross_area_result.failure, UpgradeBoardPlacementResult.Failure.OUTSIDE_AREA, "A Block cannot span multiple upgrade areas")
	_test_adjacent_area_boundary_rejection(service.rules)
	var rotated: UpgradeBoardPlacement = _find_valid_placement(service, TRI_L_PIECE, 1, empty_state, legacy_levels, 304)
	checks.truthy(rotated != null, "A rotated Block placement can be found on the single board")
	if rotated == null:
		return
	var rotated_result: UpgradeBoardPlacementResult = service.validate_placement(empty_state, rotated, legacy_levels)
	checks.truthy(rotated_result.valid, "A rotated Block can be placed entirely inside one upgrade area")
	checks.equal(rotated_result.affected_regions.size(), 1, "A valid Block has exactly one owning upgrade area")
	for rotated_cell: Vector2i in rotated_result.cells:
		checks.truthy(rotated_result.region.has_usable_cell(rotated_cell), "Every occupied cell stays inside the owning area's usable space")
	var occupied_state: UpgradeBoardState = UpgradeBoardState.new()
	occupied_state.add_placement(rotated)
	var overlap: UpgradeBoardPlacement = UpgradeBoardPlacement.new(rotated.piece, rotated.origin, rotated.rotation_index, 305)
	var overlap_result: UpgradeBoardPlacementResult = service.validate_placement(occupied_state, overlap, legacy_levels)
	checks.equal(overlap_result.failure, UpgradeBoardPlacementResult.Failure.PLACEMENT_OVERLAP, "Placement validation rejects overlap")
	var wall_cells: Array[Vector2i] = []
	wall_cells.assign(layout.walls.keys())
	checks.truthy(not wall_cells.is_empty(), "Placement validation has an authored labyrinth wall to exercise")
	if not wall_cells.is_empty():
		var wall: UpgradeBoardPlacement = UpgradeBoardPlacement.new(MONOMINO_PIECE, wall_cells[0], 0, 306)
		var wall_result: UpgradeBoardPlacementResult = service.validate_placement(empty_state, wall, legacy_levels)
		checks.equal(wall_result.failure, UpgradeBoardPlacementResult.Failure.WALL, "Placement validation rejects internal labyrinth walls")
	var partial_wall_placement: UpgradeBoardPlacement = _find_partial_wall_placement(layout)
	checks.truthy(partial_wall_placement != null, "A multi-cell Block can be positioned with one cell on an internal wall")
	if partial_wall_placement != null:
		var partial_wall_result: UpgradeBoardPlacementResult = service.validate_placement(empty_state, partial_wall_placement, legacy_levels)
		checks.equal(partial_wall_result.failure, UpgradeBoardPlacementResult.Failure.WALL, "Any wall hit rejects the complete multi-cell Block")
	var outside: UpgradeBoardPlacement = UpgradeBoardPlacement.new(MONOMINO_PIECE, Vector2i(-1, 0), 0, 307)
	var outside_result: UpgradeBoardPlacementResult = service.validate_placement(empty_state, outside, legacy_levels)
	checks.equal(outside_result.failure, UpgradeBoardPlacementResult.Failure.OUTSIDE_BOARD, "Placement validation rejects cells outside the board")
	var bypass_profile: ProfileState = ProfileState.new()
	bypass_profile.upgrade_piece_inventory.add(MONOMINO_PIECE, 1)
	var bypass_state: UpgradeBoardState = bypass_profile.upgrade_board_state.duplicate_state()
	var bypass_inventory: UpgradePieceInventory = bypass_profile.upgrade_piece_inventory.duplicate_inventory()
	bypass_state.add_placement(neutral_placement)
	checks.truthy(bypass_inventory.consume(MONOMINO_PIECE, 1), "The containment bypass fixture consumes its working-copy Block")
	var bypass_commit: UpgradeBoardCommitResult = service.commit(bypass_profile, bypass_state, bypass_inventory)
	checks.equal(bypass_commit.failure, UpgradeBoardCommitResult.Failure.INVALID_PLACEMENT, "Commit validation rejects a manually injected neutral placement")
	checks.equal(bypass_profile.upgrade_board_state.placements.size(), 0, "A rejected containment bypass leaves the confirmed board unchanged")
	checks.equal(bypass_profile.upgrade_piece_inventory.get_quantity(MONOMINO_PIECE), 1, "A rejected containment bypass leaves the persistent reserve unchanged")

func _test_completed_area_validation(layout: UpgradeBoardLayout, service: UpgradeBoardService) -> void:
	var region: UpgradeBoardRegion = layout.get_region(REWARD_INSIGHT_UPGRADE)
	checks.truthy(region != null, "Reward Reroll has an authored Upgrade Matrix area")
	if region == null:
		return
	var thresholds: PackedInt32Array = region.get_thresholds(service.rules)
	var final_threshold: int = thresholds[thresholds.size() - 1]
	checks.truthy(final_threshold < region.usable_cells.size(), "Reward Reroll leaves unused area cells after its single level")
	if final_threshold >= region.usable_cells.size():
		return
	var nearly_complete_state: UpgradeBoardState = UpgradeBoardState.new(service.rules.layout_version)
	for cell_index: int in final_threshold - 1:
		nearly_complete_state.add_placement(UpgradeBoardPlacement.new(MONOMINO_PIECE, region.usable_cells[cell_index], 0, 320 + cell_index))
	var completing_placement: UpgradeBoardPlacement = UpgradeBoardPlacement.new(MONOMINO_PIECE, region.usable_cells[final_threshold - 1], 0, 340)
	var completing_result: UpgradeBoardPlacementResult = service.validate_placement(nearly_complete_state, completing_placement, [])
	checks.truthy(completing_result.valid, "The placement that reaches a partial final threshold remains valid")
	nearly_complete_state.add_placement(completing_placement)
	var excess_placement: UpgradeBoardPlacement = UpgradeBoardPlacement.new(MONOMINO_PIECE, region.usable_cells[final_threshold], 0, 341)
	var excess_result: UpgradeBoardPlacementResult = service.validate_placement(nearly_complete_state, excess_placement, [])
	checks.equal(excess_result.failure, UpgradeBoardPlacementResult.Failure.COMPLETED_AREA, "A completed one-level area rejects excess Blocks")
	var completed_legacy_levels: Array[UpgradeLevelState] = [UpgradeLevelState.new(REWARD_INSIGHT_UPGRADE, 1)]
	var legacy_excess_result: UpgradeBoardPlacementResult = service.validate_placement(UpgradeBoardState.new(), excess_placement, completed_legacy_levels)
	checks.equal(legacy_excess_result.failure, UpgradeBoardPlacementResult.Failure.COMPLETED_AREA, "A completed legacy one-level area rejects excess Blocks")

func _test_hollow_origin_primary_selection(rules: UpgradeBoardRules) -> void:
	var hollow_layout: UpgradeBoardLayout = UpgradeBoardLayout.new(Vector2i(4, 4))
	var origin_area_cells: Array[Vector2i] = [Vector2i.ZERO]
	var occupied_area_cells: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
	var origin_region: UpgradeBoardRegion = UpgradeBoardRegion.new(ContentRegistry.upgrades[0], origin_area_cells, [], origin_area_cells, Color.WHITE, Vector2i.ZERO)
	var occupied_region: UpgradeBoardRegion = UpgradeBoardRegion.new(ContentRegistry.upgrades[1], occupied_area_cells, [], occupied_area_cells, Color.WHITE, Vector2i(1, 0))
	hollow_layout.add_region(origin_region)
	hollow_layout.add_region(occupied_region)
	var hollow_service: UpgradeBoardService = UpgradeBoardService.new(rules, hollow_layout)
	var hollow_placement: UpgradeBoardPlacement = UpgradeBoardPlacement.new(PENT_CROSS_PIECE, Vector2i.ZERO, 0, 308)
	var legacy_levels: Array[UpgradeLevelState] = []
	var hollow_result: UpgradeBoardPlacementResult = hollow_service.validate_placement(UpgradeBoardState.new(), hollow_placement, legacy_levels)
	checks.truthy(hollow_result.valid, "A hollow-origin Block is valid when all occupied offsets stay inside one area")
	checks.falsy(hollow_result.affected_regions.has(origin_region), "A hollow-origin Block does not affect the area under its unoccupied origin")
	checks.equal(hollow_result.region, occupied_region, "Primary area selection uses an actually occupied cell instead of a hollow origin")

func _test_adjacent_area_boundary_rejection(rules: UpgradeBoardRules) -> void:
	var boundary_layout: UpgradeBoardLayout = UpgradeBoardLayout.new(Vector2i(2, 1))
	var left_cells: Array[Vector2i] = [Vector2i(0, 0)]
	var right_cells: Array[Vector2i] = [Vector2i(1, 0)]
	boundary_layout.add_region(UpgradeBoardRegion.new(ContentRegistry.upgrades[0], left_cells, [], left_cells, Color.WHITE, left_cells[0]))
	boundary_layout.add_region(UpgradeBoardRegion.new(ContentRegistry.upgrades[1], right_cells, [], right_cells, Color.WHITE, right_cells[0]))
	var boundary_service: UpgradeBoardService = UpgradeBoardService.new(rules, boundary_layout)
	var boundary_placement: UpgradeBoardPlacement = UpgradeBoardPlacement.new(DOMINO_PIECE, Vector2i.ZERO, 0, 309)
	var boundary_result: UpgradeBoardPlacementResult = boundary_service.validate_placement(UpgradeBoardState.new(), boundary_placement, [])
	checks.equal(boundary_result.failure, UpgradeBoardPlacementResult.Failure.OUTSIDE_AREA, "Adjacent area cells still cannot share one Block placement")

func _test_confirmed_state_repair(
	rules: UpgradeBoardRules,
	layout: UpgradeBoardLayout,
	service: UpgradeBoardService
) -> void:
	var valid_profile: ProfileState = ProfileState.new()
	valid_profile.upgrade_piece_inventory.add(MONOMINO_PIECE, 2)
	var valid_placement: UpgradeBoardPlacement = _find_valid_placement(service, MONOMINO_PIECE, 0, valid_profile.upgrade_board_state, valid_profile.upgrade_board_legacy_progress, 401)
	valid_profile.upgrade_board_state.add_placement(valid_placement)
	var valid_data_before: Dictionary = valid_profile.to_save_data()
	valid_data_before.erase("last_modified_unix")
	var unchanged_result: UpgradeBoardRepairResult = service.repair_confirmed_state(valid_profile)
	var valid_data_after: Dictionary = valid_profile.to_save_data()
	valid_data_after.erase("last_modified_unix")
	checks.falsy(unchanged_result.repaired, "A valid current confirmed board is not repaired")
	checks.equal(valid_data_after, valid_data_before, "Valid confirmed board recovery is a complete no-op")

	var outdated_profile: ProfileState = ProfileState.new()
	outdated_profile.upgrade_piece_inventory.add(MONOMINO_PIECE, 2)
	outdated_profile.set_upgrade_level(DAMAGE_UPGRADE, 2)
	outdated_profile.upgrade_board_state.layout_version = rules.layout_version - 1
	var outdated_placement: UpgradeBoardPlacement = _find_valid_placement(service, MONOMINO_PIECE, 0, outdated_profile.upgrade_board_state, outdated_profile.upgrade_board_legacy_progress, 402)
	outdated_profile.upgrade_board_state.add_placement(outdated_placement)
	var outdated_total_blocks: int = outdated_profile.upgrade_piece_inventory.get_total_quantity() + outdated_profile.upgrade_board_state.placements.size()
	var outdated_result: UpgradeBoardRepairResult = service.repair_confirmed_state(outdated_profile)
	checks.truthy(outdated_result.repaired, "An outdated confirmed board is repaired explicitly")
	checks.equal(outdated_result.cause, UpgradeBoardRepairResult.Cause.LAYOUT_VERSION_MISMATCH, "Outdated board recovery reports a layout-version mismatch")
	checks.equal(outdated_profile.upgrade_board_state.layout_version, rules.layout_version, "Outdated board recovery stores the current layout version")
	checks.equal(outdated_profile.upgrade_board_state.placements.size(), 0, "Outdated board recovery clears confirmed placements")
	checks.equal(outdated_profile.upgrade_piece_inventory.get_total_quantity(), outdated_total_blocks, "Outdated board recovery returns every confirmed Block")
	checks.equal(outdated_profile.get_upgrade_level(DAMAGE_UPGRADE), 2, "Outdated board recovery preserves purchased progression")
	checks.equal(outdated_profile.upgrade_board_legacy_progress[0].level, 2, "Outdated board recovery converts purchased progression to foundation levels")
	var damage_region: UpgradeBoardRegion = layout.get_region(DAMAGE_UPGRADE)
	checks.equal(service.get_region_level(outdated_profile.upgrade_board_state, damage_region, outdated_profile.upgrade_board_legacy_progress), 2, "Recovered foundation cells preserve the purchased board level")
	var restored_outdated: ProfileState = ProfileState.from_save_data(outdated_profile.to_save_data())
	checks.equal(restored_outdated.upgrade_piece_inventory.get_total_quantity(), outdated_total_blocks, "Recovered Blocks survive a profile round trip")
	checks.equal(restored_outdated.get_upgrade_level(DAMAGE_UPGRADE), 2, "Recovered progression survives a profile round trip")

	var malformed_profile: ProfileState = ProfileState.new()
	malformed_profile.upgrade_piece_inventory.add(MONOMINO_PIECE, 1)
	malformed_profile.set_upgrade_level(DAMAGE_UPGRADE, 1)
	malformed_profile.upgrade_board_state.add_placement(UpgradeBoardPlacement.new(MONOMINO_PIECE, Vector2i(-1, -1), 0, 403))
	var malformed_total_blocks: int = malformed_profile.upgrade_piece_inventory.get_total_quantity() + malformed_profile.upgrade_board_state.placements.size()
	var malformed_result: UpgradeBoardRepairResult = service.repair_confirmed_state(malformed_profile)
	checks.truthy(malformed_result.repaired, "A malformed current confirmed board is repaired explicitly")
	checks.equal(malformed_result.cause, UpgradeBoardRepairResult.Cause.INVALID_CONFIRMED_PLACEMENT, "Malformed board recovery reports invalid confirmed data")
	checks.truthy(not malformed_result.invalid_reason.is_empty(), "Malformed board recovery retains its validation reason")
	checks.equal(malformed_profile.upgrade_piece_inventory.get_total_quantity(), malformed_total_blocks, "Malformed board recovery returns every confirmed Block")
	checks.equal(malformed_profile.get_upgrade_level(DAMAGE_UPGRADE), 1, "Malformed board recovery preserves purchased progression")
	checks.equal(malformed_profile.upgrade_board_legacy_progress[0].level, 1, "Malformed board recovery preserves progression as foundation cells")

	var neutral_profile: ProfileState = ProfileState.new()
	neutral_profile.upgrade_board_state.add_placement(UpgradeBoardPlacement.new(MONOMINO_PIECE, _find_neutral_cell(layout), 0, 404))
	var neutral_repair: UpgradeBoardRepairResult = service.repair_confirmed_state(neutral_profile)
	checks.truthy(neutral_repair.repaired, "A formerly valid neutral placement is recovered under area containment rules")
	checks.equal(neutral_repair.cause, UpgradeBoardRepairResult.Cause.INVALID_CONFIRMED_PLACEMENT, "Neutral placement recovery reports invalid confirmed data")
	checks.equal(neutral_profile.upgrade_board_state.placements.size(), 0, "Neutral placement recovery clears the invalid confirmed Block")
	checks.equal(neutral_profile.upgrade_piece_inventory.get_quantity(MONOMINO_PIECE), 1, "Neutral placement recovery returns the invalid confirmed Block to reserve")

func _test_staging_and_commit(layout: UpgradeBoardLayout, service: UpgradeBoardService) -> void:
	var profile: ProfileState = ProfileState.new()
	profile.upgrade_piece_inventory.add(MONOMINO_PIECE, DAMAGE_LEVEL_ONE_REQUIREMENT)
	var working_state: UpgradeBoardState = profile.upgrade_board_state.duplicate_state()
	var working_inventory: UpgradePieceInventory = profile.upgrade_piece_inventory.duplicate_inventory()
	var damage_region: UpgradeBoardRegion = layout.get_region(DAMAGE_UPGRADE)
	for index: int in DAMAGE_LEVEL_ONE_REQUIREMENT:
		var placement: UpgradeBoardPlacement = UpgradeBoardPlacement.new(MONOMINO_PIECE, damage_region.usable_cells[index], 0, 500 + index)
		var result: UpgradeBoardPlacementResult = service.validate_placement(working_state, placement, profile.upgrade_board_legacy_progress)
		checks.truthy(result.valid, "Threshold staging placement is valid: %d" % index)
		if result.valid:
			checks.truthy(working_inventory.consume(MONOMINO_PIECE, 1), "Threshold staging consumes one working-copy Block: %d" % index)
			working_state.add_placement(placement)
	checks.equal(profile.upgrade_piece_inventory.get_quantity(MONOMINO_PIECE), DAMAGE_LEVEL_ONE_REQUIREMENT, "Staging does not consume the profile inventory")
	checks.equal(profile.upgrade_board_state.placements.size(), 0, "Staging does not mutate committed profile placements")
	var commit_result: UpgradeBoardCommitResult = service.commit(profile, working_state, working_inventory)
	checks.truthy(commit_result.success, "A valid staged Upgrade Board transaction commits")
	checks.equal(profile.upgrade_piece_inventory.get_quantity(MONOMINO_PIECE), 0, "Commit consumes the staged profile inventory")
	checks.equal(profile.upgrade_board_state.placements.size(), DAMAGE_LEVEL_ONE_REQUIREMENT, "Commit stores all staged placements")
	checks.equal(profile.get_upgrade_level(DAMAGE_UPGRADE), 1, "Filling 15 Line Impact cells grants level one")
	var additional_damage_cells: int = DAMAGE_LEVEL_THREE_REQUIREMENT - DAMAGE_LEVEL_ONE_REQUIREMENT
	profile.upgrade_piece_inventory.add(MONOMINO_PIECE, additional_damage_cells)
	var expanded_state: UpgradeBoardState = profile.upgrade_board_state.duplicate_state()
	var expanded_inventory: UpgradePieceInventory = profile.upgrade_piece_inventory.duplicate_inventory()
	for index: int in range(DAMAGE_LEVEL_ONE_REQUIREMENT, DAMAGE_LEVEL_THREE_REQUIREMENT):
		var placement: UpgradeBoardPlacement = UpgradeBoardPlacement.new(MONOMINO_PIECE, damage_region.usable_cells[index], 0, 600 + index)
		if service.validate_placement(expanded_state, placement, profile.upgrade_board_legacy_progress).valid:
			expanded_inventory.consume(MONOMINO_PIECE, 1)
			expanded_state.add_placement(placement)
	var expanded_result: UpgradeBoardCommitResult = service.commit(profile, expanded_state, expanded_inventory)
	checks.truthy(expanded_result.success, "A placement batch can cross multiple upgrade thresholds")
	checks.equal(profile.get_upgrade_level(DAMAGE_UPGRADE), 3, "Filling 110 Line Impact cells grants level three")
	checks.equal(expanded_result.unlocked_upgrades.size(), 1, "A multi-level threshold crossing reports one affected upgrade")
	checks.equal(expanded_result.unlocked_level_count, 2, "A multi-level threshold crossing reports every level reached")

func _test_large_state_commit(layout: UpgradeBoardLayout, board_service: UpgradeBoardService) -> void:
	var stress_layout: UpgradeBoardLayout = UpgradeBoardLayout.new(layout.board_size)
	var stress_cells: Array[Vector2i] = []
	for stress_y: int in stress_layout.board_size.y:
		for stress_x: int in stress_layout.board_size.x:
			stress_cells.append(Vector2i(stress_x, stress_y))
	var stress_region: UpgradeBoardRegion = UpgradeBoardRegion.new(ContentRegistry.upgrades[0], stress_cells, [], stress_cells, Color.WHITE, stress_layout.board_size / 2)
	stress_layout.add_region(stress_region)
	var stress_service: UpgradeBoardService = UpgradeBoardService.new(board_service.rules, stress_layout)
	var profile: ProfileState = ProfileState.new()
	profile.upgrade_piece_inventory.add(MONOMINO_PIECE, LARGE_PLACEMENT_COUNT)
	var working_state: UpgradeBoardState = profile.upgrade_board_state.duplicate_state()
	var working_inventory: UpgradePieceInventory = profile.upgrade_piece_inventory.duplicate_inventory()
	var staged_count: int = 0
	for y: int in layout.board_size.y:
		for x: int in layout.board_size.x:
			var cell: Vector2i = Vector2i(x, y)
			if not stress_layout.is_placeable(cell):
				continue
			working_state.add_placement(UpgradeBoardPlacement.new(MONOMINO_PIECE, cell, 0, 1000 + staged_count))
			staged_count += 1
			if staged_count == LARGE_PLACEMENT_COUNT:
				break
		if staged_count == LARGE_PLACEMENT_COUNT:
			break
	checks.equal(staged_count, LARGE_PLACEMENT_COUNT, "The 100x100 board exposes thousands of open cells for the large-state regression")
	checks.truthy(working_inventory.consume(MONOMINO_PIECE, staged_count), "The large staged transaction consumes its working-copy reserve")
	var commit_result: UpgradeBoardCommitResult = stress_service.commit(profile, working_state, working_inventory)
	checks.truthy(commit_result.success, "Thousands of non-overlapping placements validate and commit in one transaction")
	checks.equal(commit_result.confirmed_placement_count, LARGE_PLACEMENT_COUNT, "Large-state commit reports every newly confirmed Block")
	checks.equal(profile.upgrade_board_state.placements.size(), LARGE_PLACEMENT_COUNT, "Large-state commit preserves every confirmed placement")
	checks.equal(profile.upgrade_piece_inventory.get_quantity(MONOMINO_PIECE), 0, "Large-state commit consumes the complete reserve")
	var synchronization_result: UpgradeBoardCommitResult = stress_service.commit(profile, profile.upgrade_board_state.duplicate_state(), profile.upgrade_piece_inventory.duplicate_inventory())
	checks.truthy(synchronization_result.success, "A large confirmed state can be revalidated without changing its placements")
	checks.equal(synchronization_result.confirmed_placement_count, 0, "Large-state revalidation confirms no duplicate placements")
	var repair_result: UpgradeBoardRepairResult = stress_service.repair_confirmed_state(profile)
	checks.falsy(repair_result.repaired, "Large confirmed-state validation leaves a correct board unchanged")
	profile.upgrade_piece_inventory.add(MONOMINO_PIECE, 1)
	var overlapping_state: UpgradeBoardState = profile.upgrade_board_state.duplicate_state()
	var overlapping_inventory: UpgradePieceInventory = profile.upgrade_piece_inventory.duplicate_inventory()
	var first_placement: UpgradeBoardPlacement = overlapping_state.placements[0]
	overlapping_state.add_placement(UpgradeBoardPlacement.new(MONOMINO_PIECE, first_placement.origin, 0, 5000))
	checks.truthy(overlapping_inventory.consume(MONOMINO_PIECE, 1), "Large-state overlap regression consumes its working-copy Block")
	var overlap_result: UpgradeBoardCommitResult = stress_service.commit(profile, overlapping_state, overlapping_inventory)
	checks.falsy(overlap_result.success, "Large-state validation still rejects an overlapping placement")
	checks.equal(overlap_result.failure, UpgradeBoardCommitResult.Failure.INVALID_PLACEMENT, "Large-state overlap reports an invalid placement transaction")

func _test_prerequisite_activation(layout: UpgradeBoardLayout, service: UpgradeBoardService) -> void:
	var profile: ProfileState = ProfileState.new()
	var dependent_region: UpgradeBoardRegion = layout.get_region(SHAPE_ARCHIVE_II_UPGRADE)
	var dependent_cell_requirement: int = dependent_region.get_thresholds(service.rules)[0]
	profile.upgrade_piece_inventory.add(MONOMINO_PIECE, dependent_cell_requirement)
	var working_state: UpgradeBoardState = profile.upgrade_board_state.duplicate_state()
	var working_inventory: UpgradePieceInventory = profile.upgrade_piece_inventory.duplicate_inventory()
	checks.truthy(_stage_region_monominoes(service, profile, working_state, working_inventory, dependent_region, dependent_cell_requirement, 6000), "A prerequisite-dependent area can reach its scaled first threshold")
	var pending_commit: UpgradeBoardCommitResult = service.commit(profile, working_state, working_inventory)
	checks.truthy(pending_commit.success, "Confirmed fill commits while an upgrade prerequisite is unmet")
	checks.equal(profile.get_upgrade_level(SHAPE_ARCHIVE_II_UPGRADE), 0, "An unmet prerequisite keeps confirmed fill pending")
	checks.equal(pending_commit.unlocked_level_count, 0, "Pending prerequisite fill reports no activated levels")
	var pending_requirement: ProgressionRequirementResult = service.get_region_activation_requirement(profile, profile.upgrade_board_state, dependent_region)
	checks.equal(pending_requirement.failure, ProgressionRequirementResult.Failure.PREREQUISITE, "Pending fill exposes its prerequisite requirement")
	checks.equal(pending_requirement.prerequisite_upgrade, SHAPE_ARCHIVE_I_UPGRADE, "Prerequisite status identifies the required upgrade")
	var prerequisite_region: UpgradeBoardRegion = layout.get_region(SHAPE_ARCHIVE_I_UPGRADE)
	var prerequisite_cell_requirement: int = prerequisite_region.get_thresholds(service.rules)[0]
	profile.upgrade_piece_inventory.add(MONOMINO_PIECE, prerequisite_cell_requirement)
	working_state = profile.upgrade_board_state.duplicate_state()
	working_inventory = profile.upgrade_piece_inventory.duplicate_inventory()
	checks.truthy(_stage_region_monominoes(service, profile, working_state, working_inventory, prerequisite_region, prerequisite_cell_requirement, 7000), "A prerequisite area can reach its scaled first threshold after its dependent area")
	var dependency_commit: UpgradeBoardCommitResult = service.commit(profile, working_state, working_inventory)
	checks.truthy(dependency_commit.success, "A dependency chain activates in one deterministic commit")
	checks.equal(profile.get_upgrade_level(SHAPE_ARCHIVE_I_UPGRADE), 1, "The prerequisite upgrade activates from its filled region")
	checks.equal(profile.get_upgrade_level(SHAPE_ARCHIVE_II_UPGRADE), 1, "Previously pending dependent fill activates in the same commit")
	checks.equal(dependency_commit.unlocked_level_count, 2, "Dependency-chain activation reports both levels")

func _test_zoom_controls(rules: UpgradeBoardRules, layout: UpgradeBoardLayout, service: UpgradeBoardService) -> void:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(800, 600)
	add_child(viewport)
	var packed_view: PackedScene = load("res://presentation/upgrade_board/upgrade_board_view.tscn") as PackedScene
	var view: UpgradeBoardView = packed_view.instantiate() as UpgradeBoardView
	viewport.add_child(view)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.setup(rules, layout, UpgradeBoardState.new(), [], service)
	await get_tree().process_frame
	await get_tree().process_frame
	view.fit_board()
	var tile_renderer: BoardTileMapRenderer = view.get_tile_map_renderer()
	checks.truthy(tile_renderer != null, "The Upgrade Board owns a reusable TileMap renderer")
	checks.truthy(tile_renderer.get_layer_count() > 0, "The Upgrade Board groups its cells into TileMap layers")
	checks.truthy(tile_renderer.get_tile_count() >= EXPECTED_BOARD_CELL_COUNT, "The TileMap contains every cell of the 100 by 100 board")
	checks.truthy(tile_renderer.tile_set_resource != null, "The TileMap path replaces the CPU overview texture")
	var matrix_rebuild_count: int = view.get_matrix_tile_rebuild_count()
	var stable_tile_count: int = tile_renderer.get_tile_count()
	view.pan_by(Vector2(24.0, 12.0))
	checks.equal(view.get_matrix_tile_rebuild_count(), matrix_rebuild_count, "Camera movement reuses the existing TileMap cells")
	view.select_region(layout.regions[0])
	checks.equal(view.get_matrix_tile_rebuild_count(), matrix_rebuild_count, "Area selection updates only its small TileMap overlay")
	view.set_board_state(UpgradeBoardState.new())
	checks.equal(view.get_matrix_tile_rebuild_count(), matrix_rebuild_count + 1, "Board-state changes rebuild static TileMap cells exactly once")
	stable_tile_count = tile_renderer.get_tile_count()
	var board_center: Vector2 = Vector2(layout.board_size) * rules.cell_pixel_size * 0.5
	view.set_camera_immediate(0.5, Vector2(viewport.size) * 0.5 - board_center * 0.5)
	var performance_zooms: Array[float] = [0.5, 1.0, 1.5, 2.0, 3.2]
	for performance_zoom: float in performance_zooms:
		view.set_camera_immediate(performance_zoom, Vector2(viewport.size) * 0.5 - board_center * performance_zoom)
		checks.equal(tile_renderer.get_tile_count(), stable_tile_count, "Zooming to %.0f percent reuses the same TileMap cells" % (performance_zoom * 100.0))
		checks.equal(view.get_matrix_tile_rebuild_count(), matrix_rebuild_count + 1, "Zooming to %.0f percent performs no board rebuild" % (performance_zoom * 100.0))
	view.set_preview([layout.regions[0].usable_cells[0]], true)
	checks.equal(view.get_matrix_tile_rebuild_count(), matrix_rebuild_count + 1, "Placement preview movement updates only dynamic TileMap cells")
	var textured_preview_count: int = 0
	for tile_entry: BoardTileMapRenderer.TileLayerEntry in tile_renderer.tile_layers:
		if tile_entry.band == BoardTileMapRenderer.LayerBand.PREVIEW and tile_entry.style == BoardTileMapRenderer.TileStyle.BLOCK_STYLE_TEXTURE:
			textured_preview_count += tile_entry.layer.get_used_cells().size()
	checks.equal(textured_preview_count, 1, "Upgrade Board previews use the shared Block texture")
	view.clear_preview()
	var camera_notifications: Array[float] = []
	view.camera_changed.connect(func(zoom: float) -> void: camera_notifications.append(zoom))
	view.focus_region(layout.regions[0])
	checks.equal(camera_notifications.back(), rules.region_focus_zoom, "Focusing a region publishes the new target zoom for the HUD")
	view.fit_board()
	var hit_test_position: Vector2 = Vector2(120.0, 120.0)
	var visible_world_before_target_zoom: Vector2 = view.get_world_position_at(hit_test_position, false)
	view.zoom_at(view.size * 0.5, rules.mouse_wheel_zoom_factor)
	var expected_visible_cell: Vector2i = Vector2i(floori(visible_world_before_target_zoom.x / rules.cell_pixel_size), floori(visible_world_before_target_zoom.y / rules.cell_pixel_size))
	checks.equal(view.get_cell_at(hit_test_position), expected_visible_cell, "Board hit-testing follows the rendered camera while zoom smoothing is active")
	view.fit_board()
	var cursor: Vector2 = Vector2(360.0, 280.0)
	var activated_cells: Array[Vector2i] = []
	view.cell_activated.connect(func(cell: Vector2i) -> void: activated_cells.append(cell))
	var middle_press: InputEventMouseButton = InputEventMouseButton.new()
	middle_press.button_index = MOUSE_BUTTON_MIDDLE
	middle_press.pressed = true
	middle_press.position = cursor
	view._gui_input(middle_press)
	var middle_release: InputEventMouseButton = InputEventMouseButton.new()
	middle_release.button_index = MOUSE_BUTTON_MIDDLE
	middle_release.pressed = false
	middle_release.position = cursor
	view._gui_input(middle_release)
	checks.equal(activated_cells.size(), 0, "A stationary middle click remains pan-only and cannot stage a Block")
	var world_before_wheel: Vector2 = view.get_world_position_at(cursor)
	var zoom_before_wheel: float = view.get_camera_zoom()
	var wheel: InputEventMouseButton = InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	wheel.position = cursor
	view._gui_input(wheel)
	var world_after_wheel: Vector2 = view.get_world_position_at(cursor)
	checks.truthy(view.get_camera_zoom() > zoom_before_wheel, "Mouse wheel zooms the Upgrade Board in")
	_check_vector_near(world_after_wheel, world_before_wheel, VECTOR_TOLERANCE, "Mouse wheel zoom keeps the cursor anchored to the same board point")
	var board_world_size: Vector2 = Vector2(layout.board_size) * rules.cell_pixel_size
	view.set_camera_immediate(1.0, (Vector2(viewport.size) - board_world_size) * 0.5)
	var tap_press: InputEventScreenTouch = InputEventScreenTouch.new()
	tap_press.index = 2
	tap_press.position = cursor
	tap_press.pressed = true
	view._gui_input(tap_press)
	var tap_release: InputEventScreenTouch = InputEventScreenTouch.new()
	tap_release.index = tap_press.index
	tap_release.position = cursor
	tap_release.pressed = false
	view._gui_input(tap_release)
	checks.equal(activated_cells.size(), 1, "A stationary one-finger tap activates one board cell")
	var pan_press: InputEventScreenTouch = InputEventScreenTouch.new()
	pan_press.index = 3
	pan_press.position = cursor
	pan_press.pressed = true
	view._gui_input(pan_press)
	var world_before_touch_pan: Vector2 = view.get_world_position_at(cursor)
	var touch_pan: InputEventScreenDrag = InputEventScreenDrag.new()
	touch_pan.index = pan_press.index
	touch_pan.position = cursor + Vector2(80.0, 0.0)
	touch_pan.relative = Vector2(80.0, 0.0)
	view._gui_input(touch_pan)
	var pan_release: InputEventScreenTouch = InputEventScreenTouch.new()
	pan_release.index = pan_press.index
	pan_release.position = touch_pan.position
	pan_release.pressed = false
	view._gui_input(pan_release)
	checks.equal(activated_cells.size(), 1, "A one-finger drag pans without activating another cell")
	checks.truthy(not view.get_world_position_at(cursor).is_equal_approx(world_before_touch_pan), "A one-finger drag changes the visible board position")
	view.set_camera_immediate(1.0, (Vector2(viewport.size) - board_world_size) * 0.5)
	view.set_placement_mode_enabled(true)
	var placement_cells: Array[Vector2i] = []
	var rotation_requests: Array[bool] = []
	var confirmation_request_count: Array[int] = [0]
	view.placement_cell_changed.connect(func(cell: Vector2i) -> void: placement_cells.append(cell))
	view.rotation_requested.connect(func(clockwise: bool) -> void: rotation_requests.append(clockwise))
	view.placement_confirmation_requested.connect(func() -> void: confirmation_request_count[0] += 1)
	var placement_press: InputEventScreenTouch = InputEventScreenTouch.new()
	placement_press.index = 5
	placement_press.position = cursor
	placement_press.pressed = true
	view._gui_input(placement_press)
	var placement_world_before_drag: Vector2 = view.get_world_position_at(cursor)
	var placement_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	placement_drag.index = placement_press.index
	placement_drag.position = cursor + Vector2(64.0, 0.0)
	placement_drag.relative = Vector2(64.0, 0.0)
	view._gui_input(placement_drag)
	var placement_release: InputEventScreenTouch = InputEventScreenTouch.new()
	placement_release.index = placement_press.index
	placement_release.position = placement_drag.position
	placement_release.pressed = false
	view._gui_input(placement_release)
	checks.equal(rotation_requests, [true], "Swiping away from the placement preview rotates the selected Matrix Block clockwise")
	checks.truthy(placement_cells.is_empty(), "A rotation swipe does not displace the selected Matrix Block")
	_check_vector_near(view.get_world_position_at(cursor), placement_world_before_drag, VECTOR_TOLERANCE, "Dragging a placement candidate does not pan the board")
	view.set_preview([view.get_cell_at(cursor)], true)
	var preview_drag_press: InputEventScreenTouch = InputEventScreenTouch.new()
	preview_drag_press.index = 6
	preview_drag_press.position = cursor
	preview_drag_press.pressed = true
	view._gui_input(preview_drag_press)
	var preview_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	preview_drag.index = preview_drag_press.index
	preview_drag.position = cursor + Vector2(64.0, 0.0)
	preview_drag.relative = Vector2(64.0, 0.0)
	view._gui_input(preview_drag)
	var preview_drag_release: InputEventScreenTouch = InputEventScreenTouch.new()
	preview_drag_release.index = preview_drag_press.index
	preview_drag_release.position = preview_drag.position
	preview_drag_release.pressed = false
	view._gui_input(preview_drag_release)
	checks.truthy(not placement_cells.is_empty(), "Dragging from the active preview moves the Matrix Block across board cells")
	view.set_preview([view.get_cell_at(cursor)], true)
	var preview_tap_press: InputEventScreenTouch = InputEventScreenTouch.new()
	preview_tap_press.index = 7
	preview_tap_press.position = cursor
	preview_tap_press.pressed = true
	view._gui_input(preview_tap_press)
	var preview_tap_release: InputEventScreenTouch = InputEventScreenTouch.new()
	preview_tap_release.index = preview_tap_press.index
	preview_tap_release.position = cursor
	preview_tap_release.pressed = false
	view._gui_input(preview_tap_release)
	checks.equal(confirmation_request_count[0], 1, "Tapping an armed Matrix preview requests placement like the run board")
	var preview_mouse_press: InputEventMouseButton = InputEventMouseButton.new()
	preview_mouse_press.button_index = MOUSE_BUTTON_LEFT
	preview_mouse_press.pressed = true
	preview_mouse_press.position = cursor
	view._gui_input(preview_mouse_press)
	var preview_mouse_release: InputEventMouseButton = InputEventMouseButton.new()
	preview_mouse_release.button_index = MOUSE_BUTTON_LEFT
	preview_mouse_release.pressed = false
	preview_mouse_release.position = cursor
	view._gui_input(preview_mouse_release)
	checks.equal(confirmation_request_count[0], 2, "Clicking an armed Matrix preview requests placement like the run board")
	var placement_signal_count_before_mouse_drag: int = placement_cells.size()
	var placement_mouse_press: InputEventMouseButton = InputEventMouseButton.new()
	placement_mouse_press.button_index = MOUSE_BUTTON_LEFT
	placement_mouse_press.pressed = true
	placement_mouse_press.position = cursor
	view._gui_input(placement_mouse_press)
	var placement_mouse_motion: InputEventMouseMotion = InputEventMouseMotion.new()
	placement_mouse_motion.position = cursor + Vector2(64.0, 0.0)
	placement_mouse_motion.relative = Vector2(64.0, 0.0)
	view._gui_input(placement_mouse_motion)
	var placement_mouse_release: InputEventMouseButton = InputEventMouseButton.new()
	placement_mouse_release.button_index = MOUSE_BUTTON_LEFT
	placement_mouse_release.pressed = false
	placement_mouse_release.position = placement_mouse_motion.position
	view._gui_input(placement_mouse_release)
	checks.equal(placement_cells.size() - placement_signal_count_before_mouse_drag, 1, "Mouse candidate dragging does not duplicate placement signals for the same motion event")
	view.set_placement_mode_enabled(false)
	var magnify: InputEventMagnifyGesture = InputEventMagnifyGesture.new()
	magnify.position = cursor
	magnify.factor = 1.1
	var zoom_before_magnify: float = view.get_camera_zoom()
	view._gui_input(magnify)
	checks.truthy(view.get_camera_zoom() > zoom_before_magnify, "Trackpad magnification zooms the Upgrade Board")
	var world_before_trackpad_pan: Vector2 = view.get_world_position_at(cursor)
	var trackpad_pan: InputEventPanGesture = InputEventPanGesture.new()
	trackpad_pan.position = cursor
	trackpad_pan.delta = Vector2(12.0, 6.0)
	view._gui_input(trackpad_pan)
	checks.truthy(not view.get_world_position_at(cursor).is_equal_approx(world_before_trackpad_pan), "Trackpad panning changes the visible board position")
	view.set_camera_immediate(1.0, (Vector2(viewport.size) - board_world_size) * 0.5)
	var first_position: Vector2 = Vector2(300.0, 300.0)
	var second_position: Vector2 = Vector2(500.0, 300.0)
	var previous_midpoint: Vector2 = (first_position + second_position) * 0.5
	var first_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	first_touch.index = 0
	first_touch.position = first_position
	first_touch.pressed = true
	view._gui_input(first_touch)
	var second_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	second_touch.index = 1
	second_touch.position = second_position
	second_touch.pressed = true
	view._gui_input(second_touch)
	var world_before_pinch: Vector2 = view.get_world_position_at(previous_midpoint)
	var second_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	second_drag.index = 1
	second_drag.position = Vector2(600.0, 300.0)
	second_drag.relative = Vector2(100.0, 0.0)
	view._gui_input(second_drag)
	var current_midpoint: Vector2 = (first_position + second_drag.position) * 0.5
	var world_after_pinch: Vector2 = view.get_world_position_at(current_midpoint)
	checks.equal(view.get_camera_zoom(), 1.5, "Two-touch pinch scales the Upgrade Board by the finger-distance ratio")
	_check_vector_near(world_after_pinch, world_before_pinch, VECTOR_TOLERANCE, "Two-touch pinch keeps the moving midpoint anchored to the same board point")
	var first_release: InputEventScreenTouch = InputEventScreenTouch.new()
	first_release.index = 0
	first_release.position = first_position
	first_release.pressed = false
	view._gui_input(first_release)
	var second_release: InputEventScreenTouch = InputEventScreenTouch.new()
	second_release.index = 1
	second_release.position = second_drag.position
	second_release.pressed = false
	view._gui_input(second_release)
	viewport.queue_free()
	await get_tree().process_frame

func _test_upgrade_tree_layout() -> void:
	for piece: PieceDefinition in ContentRegistry.pieces:
		SaveService.profile.upgrade_piece_inventory.add(piece, 1)
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var packed_screen: PackedScene = load("res://scenes/upgrades/upgrade_tree_screen.tscn") as PackedScene
	var screen: UpgradeTreeScreen = packed_screen.instantiate() as UpgradeTreeScreen
	screen.theme = load("res://presentation/theme/game_theme.tres") as Theme
	viewport.add_child(screen)
	await get_tree().process_frame
	await get_tree().process_frame
	var layout_control: Control = screen.get_node("Margin/Layout") as Control
	var layout_rect: Rect2 = layout_control.get_global_rect()
	checks.truthy(layout_rect.position.x >= 0.0 and layout_rect.position.y >= 0.0 and layout_rect.end.x <= 1280.0 and layout_rect.end.y <= 720.0, "Upgrade Tree layout fits inside 1280x720")
	var piece_tray: HBoxContainer = screen.get_node("Margin/Layout/ActionBar/Actions/PieceScroll/PieceTray") as HBoxContainer
	var piece_scroll: ScrollContainer = screen.get_node("Margin/Layout/ActionBar/Actions/PieceScroll") as ScrollContainer
	var confirm: Button = screen.get_node("Margin/Layout/ActionBar/Actions/Confirm") as Button
	var actions: HBoxContainer = screen.get_node("Margin/Layout/ActionBar/Actions") as HBoxContainer
	var detail_panel: Control = screen.get_node("Margin/Layout/Workspace/DetailPanel") as Control
	var keyboard_legend: PanelContainer = screen.get_node("Margin/Layout/Workspace/BoardPanel/BoardMargin/BoardLayer/KeyboardLegend") as PanelContainer
	checks.truthy(piece_tray != null and piece_tray.is_visible_in_tree(), "Upgrade Tree exposes the current-piece tray")
	checks.truthy(confirm != null and confirm.is_visible_in_tree(), "Upgrade Tree exposes the confirmation action")
	checks.truthy(keyboard_legend != null and keyboard_legend.is_visible_in_tree(), "Upgrade Matrix shows its Q and E rotation legend")
	var board_layer: Control = screen.get_node("Margin/Layout/Workspace/BoardPanel/BoardMargin/BoardLayer") as Control
	checks.truthy(keyboard_legend.position.x > board_layer.size.x * 0.5 and keyboard_legend.position.y > board_layer.size.y * 0.5, "Upgrade Matrix rotation legend stays in the board's bottom-right corner")
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.PROGRESSION_UPGRADE_ACTIONS), actions, "Upgrade Matrix action bar is registered for tutorials")
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.PROGRESSION_UPGRADE_DETAILS), detail_panel, "Upgrade Matrix detail panel is registered for tutorials")
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.PROGRESSION_UPGRADE_CONFIRM), confirm, "Upgrade Matrix confirmation is registered for tutorials")
	screen._select_piece(TRI_L_PIECE)
	var initial_rotation: int = screen.selected_rotation_index
	var right_key: InputEventKey = InputEventKey.new()
	right_key.physical_keycode = KEY_E
	right_key.pressed = true
	screen._unhandled_input(right_key)
	checks.equal(screen.selected_rotation_index, posmod(initial_rotation + 1, PieceRotationService.get_unique_rotations(TRI_L_PIECE).size()), "E rotates a Matrix Block clockwise")
	var left_key: InputEventKey = InputEventKey.new()
	left_key.physical_keycode = KEY_Q
	left_key.pressed = true
	screen._unhandled_input(left_key)
	checks.equal(screen.selected_rotation_index, initial_rotation, "Q rotates a Matrix Block counterclockwise")
	screen._cancel_placement_candidate(true)
	var first_card: UpgradeBoardPieceCard
	for child: Node in piece_tray.get_children():
		if child is UpgradeBoardPieceCard:
			first_card = child as UpgradeBoardPieceCard
			break
	checks.truthy(first_card != null, "Populated Block reserve renders piece cards")
	if first_card == null:
		viewport.queue_free()
		await get_tree().process_frame
		return
	var scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	scroll_press.index = 4
	scroll_press.position = first_card.get_global_rect().get_center()
	scroll_press.pressed = true
	screen._input(scroll_press)
	var scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	scroll_drag.index = scroll_press.index
	scroll_drag.position = scroll_press.position - Vector2(180.0, 0.0)
	scroll_drag.relative = Vector2(-180.0, 0.0)
	screen._input(scroll_drag)
	checks.truthy(piece_scroll.scroll_horizontal > 0, "Swiping from a reserve card scrolls the horizontal Block tray")
	var scroll_release: InputEventScreenTouch = InputEventScreenTouch.new()
	scroll_release.index = scroll_press.index
	scroll_release.position = scroll_drag.position
	scroll_release.pressed = false
	screen._input(scroll_release)
	checks.equal(screen.reserve_touch_index, -1, "Block reserve touch scrolling releases its tracked finger")
	piece_scroll.scroll_horizontal = 0
	var board_view: UpgradeBoardView = screen.get_node("Margin/Layout/Workspace/BoardPanel/BoardMargin/BoardLayer/BoardView") as UpgradeBoardView
	var place_button: Button = screen.get_node("Margin/Layout/ActionBar/Actions/Place") as Button
	var initial_placement_count: int = screen.working_state.placements.size()
	var wall_collision_candidate: UpgradeBoardPlacement = _find_partial_wall_placement(screen.layout)
	checks.truthy(wall_collision_candidate != null, "The placement UI has a partial-wall collision fixture")
	if wall_collision_candidate != null:
		screen._select_piece(wall_collision_candidate.piece)
		screen._move_placement_candidate(wall_collision_candidate.origin)
		checks.falsy(screen.placement_candidate_valid, "A candidate becomes invalid when any occupied cell hits a wall")
		checks.falsy(board_view.preview_valid, "A wall collision renders the complete candidate as invalid")
		checks.truthy(place_button.disabled, "PLACE remains disabled while any part of the Block hits a wall")
		screen._cancel_placement_candidate(true)
	screen._select_piece(MONOMINO_PIECE)
	checks.truthy(screen.placement_candidate != null, "Selecting a reserve Block creates a movable placement candidate")
	var first_candidate_position: UpgradeBoardPlacement = _find_valid_placement(screen.board_service, MONOMINO_PIECE, 0, screen.working_state, SaveService.profile.upgrade_board_legacy_progress, 9001)
	checks.truthy(first_candidate_position != null, "A reserve placement candidate can find an open board position")
	if first_candidate_position != null:
		screen._move_placement_candidate(first_candidate_position.origin)
		checks.equal(screen.working_state.placements.size(), initial_placement_count, "Moving a placement candidate does not stage it on the first tap")
		checks.truthy(screen.placement_candidate_positioned, "Pointer movement positions the selected Block preview")
		screen._stage_placement_candidate()
		checks.equal(screen.working_state.placements.size(), initial_placement_count + 1, "PLACE explicitly stages the positioned Block")
		checks.equal(screen.staged_placement_tokens.size(), 1, "The explicitly placed Block remains pending until confirmation")
		var staged_placement: UpgradeBoardPlacement = screen.working_state.placements.back()
		var staged_placement_token: int = staged_placement.placement_token
		var staged_origin: Vector2i = staged_placement.origin
		screen._handle_board_cell(staged_origin)
		checks.truthy(screen.placement_candidate != null and screen.placement_source == UpgradeTreeScreen.PlacementSource.STAGED, "Tapping a staged Block picks it back up for editing")
		checks.equal(screen.working_state.placements.size(), initial_placement_count, "A picked-up staged Block becomes a movable preview")
		var moved_candidate_position: UpgradeBoardPlacement = _find_different_valid_placement(screen.board_service, MONOMINO_PIECE, 0, screen.working_state, SaveService.profile.upgrade_board_legacy_progress, staged_origin, 9002)
		checks.truthy(moved_candidate_position != null, "A staged Block can find a different valid position")
		if moved_candidate_position != null:
			screen._move_placement_candidate(moved_candidate_position.origin)
			screen._stage_placement_candidate()
			var moved_placement: UpgradeBoardPlacement = screen.working_state.placements.back()
			checks.equal(moved_placement.placement_token, staged_placement_token, "Moving a staged Block preserves its stable placement identity")
			checks.equal(moved_placement.origin, moved_candidate_position.origin, "PLACE restages the Block at its moved position")
			checks.equal(screen.staged_placement_tokens.size(), 1, "Moving a staged Block does not create a duplicate pending placement")
			var confirmed_position: UpgradeBoardPlacement = _find_different_valid_placement(screen.board_service, MONOMINO_PIECE, 0, screen.working_state, SaveService.profile.upgrade_board_legacy_progress, moved_placement.origin, 9003)
			if confirmed_position != null:
				screen.working_state.add_placement(confirmed_position)
				screen._handle_board_cell(confirmed_position.origin)
				checks.truthy(screen.placement_candidate == null, "Tapping a confirmed Block does not make the permanent placement movable")
			screen._undo_last_placement()
			checks.truthy(screen.placement_candidate == null, "Undo returns the last staged Block without forcing a new placement candidate")
			checks.truthy(screen.staged_placement_tokens.is_empty(), "Undo removes the pending placement while preserving confirmed Blocks")
	var foundry: UpgradeBoardShopDialog = screen.get_node("Foundry") as UpgradeBoardShopDialog
	foundry.open()
	await get_tree().process_frame
	checks.truthy(foundry.visible, "The Matrix exposes its own Fragment Block foundry")
	checks.equal(foundry.catalog_items.size(), _count_unlocked_pieces(SaveService.profile), "The Matrix foundry displays only the profile's unlocked Block catalog")
	if not foundry_screenshot_path.is_empty():
		var foundry_screenshot: Image = viewport.get_texture().get_image()
		checks.truthy(foundry_screenshot != null and foundry_screenshot.save_png(foundry_screenshot_path) == OK, "Matrix foundry screenshot is saved")
	foundry.close()
	var board_world_center: Vector2 = Vector2(screen.layout.board_size) * screen.board_rules.cell_pixel_size * 0.5
	var matrix_renderer: BoardTileMapRenderer = board_view.get_tile_map_renderer()
	var matrix_tile_count: int = matrix_renderer.get_tile_count()
	var matrix_rebuild_count: int = board_view.get_matrix_tile_rebuild_count()
	var performance_zooms: Array[float] = [1.0, 1.5, 2.0]
	for performance_zoom: float in performance_zooms:
		board_view.set_camera_immediate(performance_zoom, board_view.size * 0.5 - board_world_center * performance_zoom)
		screen._update_zoom_label(performance_zoom)
		checks.equal(matrix_renderer.get_tile_count(), matrix_tile_count, "The full Matrix UI reuses TileMap cells at %d percent zoom" % roundi(performance_zoom * 100.0))
		checks.equal(board_view.get_matrix_tile_rebuild_count(), matrix_rebuild_count, "The full Matrix UI performs no board rebuild at %d percent zoom" % roundi(performance_zoom * 100.0))
	board_view.fit_board()
	for frame_index: int in 12:
		await get_tree().process_frame
	if not screenshot_path.is_empty():
		var screenshot: Image = viewport.get_texture().get_image()
		checks.truthy(screenshot != null and screenshot.save_png(screenshot_path) == OK, "Full 100x100 Upgrade Board screenshot is saved")
	viewport.queue_free()
	await get_tree().process_frame

func _cells_are_connected(cells: Array[Vector2i]) -> bool:
	if cells.is_empty():
		return false
	var available_cells: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in cells:
		available_cells[cell] = true
	var visited_cells: Dictionary[Vector2i, bool] = {}
	var pending_cells: Array[Vector2i] = [cells[0]]
	var pending_index: int = 0
	visited_cells[cells[0]] = true
	while pending_index < pending_cells.size():
		var current_cell: Vector2i = pending_cells[pending_index]
		pending_index += 1
		for direction: Vector2i in CARDINAL_DIRECTIONS:
			var neighbor: Vector2i = current_cell + direction
			if available_cells.has(neighbor) and not visited_cells.has(neighbor):
				visited_cells[neighbor] = true
				pending_cells.append(neighbor)
	return visited_cells.size() == cells.size()

func _find_neutral_cell(layout: UpgradeBoardLayout) -> Vector2i:
	for y: int in EXPECTED_BOARD_SIZE.y:
		for x: int in EXPECTED_BOARD_SIZE.x:
			var cell: Vector2i = Vector2i(x, y)
			if layout.get_region_at(cell) == null:
				return cell
	return Vector2i(-1, -1)

func _find_spanning_placement(
	layout: UpgradeBoardLayout,
	minimum_region_count: int,
	maximum_region_count: int,
	requires_neutral_cell: bool,
	placement_token: int
) -> UpgradeBoardPlacement:
	for piece: PieceDefinition in ContentRegistry.pieces:
		var rotations: Array[Array] = PieceRotationService.get_unique_rotations(piece)
		for rotation_index: int in rotations.size():
			for y: int in EXPECTED_BOARD_SIZE.y:
				for x: int in EXPECTED_BOARD_SIZE.x:
					var origin: Vector2i = Vector2i(x, y)
					var affected_regions: Array[UpgradeBoardRegion] = []
					var contains_neutral_cell: bool = false
					var cells_are_open: bool = true
					for cell_value: Variant in rotations[rotation_index]:
						var cell: Vector2i = origin + (cell_value as Vector2i)
						if not layout.is_within_bounds(cell) or layout.is_wall(cell):
							cells_are_open = false
							break
						var cell_region: UpgradeBoardRegion = layout.get_region_at(cell)
						if cell_region == null:
							contains_neutral_cell = true
						elif not affected_regions.has(cell_region):
							affected_regions.append(cell_region)
					if not cells_are_open or affected_regions.size() < minimum_region_count or affected_regions.size() > maximum_region_count:
						continue
					if contains_neutral_cell == requires_neutral_cell:
						return UpgradeBoardPlacement.new(piece, origin, rotation_index, placement_token)
	return null

func _find_partial_wall_placement(layout: UpgradeBoardLayout) -> UpgradeBoardPlacement:
	for piece: PieceDefinition in ContentRegistry.pieces:
		if piece.base_cells.size() < 2:
			continue
		var rotations: Array[Array] = PieceRotationService.get_unique_rotations(piece)
		for rotation_index: int in rotations.size():
			for y: int in EXPECTED_BOARD_SIZE.y:
				for x: int in EXPECTED_BOARD_SIZE.x:
					var origin: Vector2i = Vector2i(x, y)
					var owner: UpgradeBoardRegion
					var hits_wall: bool = false
					var usable_cell_count: int = 0
					var contained_in_one_area: bool = true
					for cell_value: Variant in rotations[rotation_index]:
						var cell: Vector2i = origin + (cell_value as Vector2i)
						if not layout.is_within_bounds(cell):
							contained_in_one_area = false
							break
						var region: UpgradeBoardRegion = layout.get_region_at(cell)
						if region == null or owner != null and region != owner:
							contained_in_one_area = false
							break
						if owner == null:
							owner = region
						if layout.is_wall(cell):
							hits_wall = true
						elif region.has_usable_cell(cell):
							usable_cell_count += 1
						else:
							contained_in_one_area = false
							break
					if contained_in_one_area and hits_wall and usable_cell_count > 0:
						return UpgradeBoardPlacement.new(piece, origin, rotation_index, 9100)
	return null

func _find_valid_placement(
	service: UpgradeBoardService,
	piece: PieceDefinition,
	rotation_index: int,
	state: UpgradeBoardState,
	legacy_levels: Array[UpgradeLevelState],
	placement_token: int
) -> UpgradeBoardPlacement:
	for y: int in EXPECTED_BOARD_SIZE.y:
		for x: int in EXPECTED_BOARD_SIZE.x:
			var candidate: UpgradeBoardPlacement = UpgradeBoardPlacement.new(piece, Vector2i(x, y), rotation_index, placement_token)
			if service.validate_placement(state, candidate, legacy_levels).valid:
				return candidate
	return null

func _find_different_valid_placement(
	service: UpgradeBoardService,
	piece: PieceDefinition,
	rotation_index: int,
	state: UpgradeBoardState,
	legacy_levels: Array[UpgradeLevelState],
	excluded_origin: Vector2i,
	placement_token: int
) -> UpgradeBoardPlacement:
	for y: int in range(EXPECTED_BOARD_SIZE.y - 1, -1, -1):
		for x: int in range(EXPECTED_BOARD_SIZE.x - 1, -1, -1):
			var origin: Vector2i = Vector2i(x, y)
			if origin == excluded_origin:
				continue
			var candidate: UpgradeBoardPlacement = UpgradeBoardPlacement.new(piece, origin, rotation_index, placement_token)
			if service.validate_placement(state, candidate, legacy_levels).valid:
				return candidate
	return null

func _stage_region_monominoes(
	service: UpgradeBoardService,
	profile: ProfileState,
	state: UpgradeBoardState,
	inventory: UpgradePieceInventory,
	region: UpgradeBoardRegion,
	cell_count: int,
	placement_token_base: int
) -> bool:
	if region == null or cell_count < 0 or cell_count > region.usable_cells.size():
		return false
	for index: int in cell_count:
		var placement: UpgradeBoardPlacement = UpgradeBoardPlacement.new(MONOMINO_PIECE, region.usable_cells[index], 0, placement_token_base + index)
		if not service.validate_placement(state, placement, profile.upgrade_board_legacy_progress).valid:
			return false
		if not inventory.consume(MONOMINO_PIECE, 1):
			return false
		state.add_placement(placement)
	return true

func _find_region_slot(rules: UpgradeBoardRules, upgrade: UpgradeDefinition) -> UpgradeBoardRegionSlot:
	for region_slot: UpgradeBoardRegionSlot in rules.region_slots:
		if region_slot != null and region_slot.upgrade == upgrade:
			return region_slot
	return null

func _find_region_slot_at(rules: UpgradeBoardRules, slot_index: int) -> UpgradeBoardRegionSlot:
	for region_slot: UpgradeBoardRegionSlot in rules.region_slots:
		if region_slot != null and region_slot.slot_index == slot_index:
			return region_slot
	return null

func _find_shop_item(shop: ShopState, piece: PieceDefinition) -> ShopItem:
	if shop == null:
		return null
	for item: ShopItem in shop.items:
		if item.piece == piece:
			return item
	return null

func _count_unlocked_pieces(profile: ProfileState) -> int:
	var count: int = 0
	for piece: PieceDefinition in ContentRegistry.pieces:
		if piece.initially_unlocked or profile.unlocked_pieces.has(piece):
			count += 1
	return count

func _check_vector_near(actual: Vector2, expected: Vector2, tolerance: float, label: String) -> void:
	checks.truthy(actual.distance_to(expected) <= tolerance, label)

func _get_screenshot_path() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--screenshot="):
			return argument.trim_prefix("--screenshot=")
	return ""

func _get_foundry_screenshot_path() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--foundry-screenshot="):
			return argument.trim_prefix("--foundry-screenshot=")
	return ""
