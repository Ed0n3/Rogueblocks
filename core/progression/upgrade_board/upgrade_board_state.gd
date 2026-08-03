class_name UpgradeBoardState
extends Resource

const UNVERSIONED_LAYOUT_VERSION: int = 0

var layout_version: int
var placements: Array[UpgradeBoardPlacement] = []

func _init(persisted_layout_version: Variant = null) -> void:
	var default_layout_version: int = UpgradeMatrixConfiguration.load_default().progression.layout_version
	layout_version = default_layout_version if persisted_layout_version == null else int(persisted_layout_version)

func add_placement(placement: UpgradeBoardPlacement) -> void:
	if placement != null:
		placements.append(placement)

func remove_placement(placement: UpgradeBoardPlacement) -> void:
	placements.erase(placement)

func duplicate_state() -> UpgradeBoardState:
	var duplicated: UpgradeBoardState = UpgradeBoardState.new(layout_version)
	for placement: UpgradeBoardPlacement in placements:
		duplicated.placements.append(placement.duplicate_placement())
	return duplicated

func sanitize(known_pieces: Array[PieceDefinition]) -> void:
	var sanitized: Array[UpgradeBoardPlacement] = []
	for placement: UpgradeBoardPlacement in placements:
		if placement == null or placement.piece == null or not known_pieces.has(placement.piece):
			continue
		sanitized.append(placement)
	placements = sanitized

func to_save_data() -> Dictionary:
	var placement_data: Array[Dictionary] = []
	for placement: UpgradeBoardPlacement in placements:
		placement_data.append(placement.to_save_data())
	return {
		"layout_version": layout_version,
		"placements": placement_data,
	}

static func from_save_data(data: Dictionary) -> UpgradeBoardState:
	var state: UpgradeBoardState = UpgradeBoardState.new()
	state.layout_version = int(data.get("layout_version", UNVERSIONED_LAYOUT_VERSION))
	for placement_value: Variant in data.get("placements", []) as Array:
		if placement_value is Dictionary:
			state.placements.append(UpgradeBoardPlacement.from_save_data(placement_value as Dictionary))
	return state
