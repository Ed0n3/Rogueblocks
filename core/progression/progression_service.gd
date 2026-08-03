class_name ProgressionService
extends RefCounted

signal purchase_completed(result: PurchaseResult)

@export_category("Messages")
@export var missing_profile_message: String = "The profile is unavailable."
@export var invalid_upgrade_message: String = "Invalid upgrade definition."
@export var maximum_level_message: String = "Maximum level reached"
@export var insufficient_fragments_message: String = "Not enough Fragments"
@export var prerequisite_message: String = "Requires %s level %d (%d/%d)."
@export var victories_message: String = "Requires %d victories (%d/%d)."
@export var difficulty_message: String = "Requires difficulty tier %d completed (%d/%d)."
@export var mutual_exclusivity_message: String = "Conflicts with active upgrade %s."

var upgrades: Array[UpgradeDefinition]

func _init(available_upgrades: Array[UpgradeDefinition] = []) -> void:
	upgrades = available_upgrades

func can_purchase(profile: ProfileState, upgrade: UpgradeDefinition) -> PurchaseValidationResult:
	var result: PurchaseValidationResult = PurchaseValidationResult.new()
	if profile == null:
		result.reason = missing_profile_message
		return result
	if upgrade == null or not upgrade.is_valid():
		result.reason = invalid_upgrade_message
		return result
	var current_level: int = profile.get_upgrade_level(upgrade)
	if current_level >= upgrade.max_level:
		result.reason = maximum_level_message
		return result
	result.cost = upgrade.get_cost_for_level(current_level)
	if profile.fragments < result.cost:
		result.reason = insufficient_fragments_message
		return result
	var requirements: ProgressionRequirementResult = check_requirements(profile, upgrade)
	if not requirements.allowed:
		result.reason = requirements.reason
		return result
	result.allowed = true
	return result

func check_requirements(
	profile: ProfileState,
	upgrade: UpgradeDefinition,
	projected_levels: Dictionary[UpgradeDefinition, int] = {}
) -> ProgressionRequirementResult:
	if profile == null:
		return ProgressionRequirementResult.rejected(ProgressionRequirementResult.Failure.MISSING_PROFILE, missing_profile_message)
	if upgrade == null or not upgrade.is_valid():
		return ProgressionRequirementResult.rejected(ProgressionRequirementResult.Failure.INVALID_UPGRADE, invalid_upgrade_message)
	for index: int in upgrade.prerequisite_upgrades.size():
		var prerequisite: UpgradeDefinition = upgrade.prerequisite_upgrades[index]
		var required_level: int = upgrade.prerequisite_levels[index]
		var current_level: int = _get_projected_level(profile, projected_levels, prerequisite)
		if current_level < required_level:
			var prerequisite_name: String = prerequisite.display_name
			var prerequisite_reason: String = prerequisite_message % [prerequisite_name, required_level, current_level, required_level]
			return ProgressionRequirementResult.rejected(ProgressionRequirementResult.Failure.PREREQUISITE, prerequisite_reason, prerequisite, required_level, current_level)
	if profile.victories < upgrade.required_victories:
		var victory_reason: String = victories_message % [upgrade.required_victories, profile.victories, upgrade.required_victories]
		return ProgressionRequirementResult.rejected(ProgressionRequirementResult.Failure.VICTORIES, victory_reason, null, upgrade.required_victories, profile.victories)
	if profile.highest_difficulty_completed < upgrade.required_highest_difficulty:
		var difficulty_reason: String = difficulty_message % [upgrade.required_highest_difficulty, profile.highest_difficulty_completed, upgrade.required_highest_difficulty]
		return ProgressionRequirementResult.rejected(ProgressionRequirementResult.Failure.DIFFICULTY, difficulty_reason, null, upgrade.required_highest_difficulty, profile.highest_difficulty_completed)
	for incompatible: UpgradeDefinition in upgrade.incompatible_upgrades:
		if _get_projected_level(profile, projected_levels, incompatible) > 0:
			var conflict_reason: String = mutual_exclusivity_message % incompatible.display_name
			return ProgressionRequirementResult.rejected(ProgressionRequirementResult.Failure.MUTUAL_EXCLUSIVITY, conflict_reason, null, 0, 0, incompatible)
	return ProgressionRequirementResult.accepted()

func get_next_level_cost(profile: ProfileState, upgrade: UpgradeDefinition) -> int:
	return upgrade.get_cost_for_level(profile.get_upgrade_level(upgrade))

func purchase_upgrade(profile: ProfileState, upgrade: UpgradeDefinition) -> PurchaseResult:
	var validation: PurchaseValidationResult = can_purchase(profile, upgrade)
	var result: PurchaseResult = PurchaseResult.new()
	result.upgrade = upgrade
	if not validation.allowed:
		result.reason = validation.reason
		return result
	var current_level: int = profile.get_upgrade_level(upgrade)
	profile.fragments -= validation.cost
	profile.total_fragments_spent += validation.cost
	profile.set_upgrade_level(upgrade, current_level + 1)
	for effect: PermanentUpgradeEffect in upgrade.effects:
		if effect is UnlockContentEffect:
			(effect as UnlockContentEffect).apply_to_profile(profile)
	result.success = true
	result.new_level = current_level + 1
	result.spent_fragments = validation.cost
	purchase_completed.emit(result)
	return result

func resolve_starting_modifiers(profile: ProfileState) -> StartingRunModifiers:
	var modifiers: StartingRunModifiers = StartingRunModifiers.new()
	snapshot_content_unlocks(profile, modifiers)
	for upgrade: UpgradeDefinition in upgrades:
		var level: int = profile.get_upgrade_level(upgrade)
		if level <= 0:
			continue
		for effect: PermanentUpgradeEffect in upgrade.effects:
			effect.apply_to_starting_modifiers(modifiers, level, upgrade)
	modifiers.starting_rerolls_bonus = clampi(modifiers.starting_rerolls_bonus, modifiers.minimum_starting_rerolls, modifiers.maximum_starting_rerolls)
	modifiers.draw_count_bonus = clampi(modifiers.draw_count_bonus, modifiers.minimum_draw_count_bonus, modifiers.maximum_draw_count_bonus)
	modifiers.shop_discount = clampf(modifiers.shop_discount, 0.0, modifiers.maximum_shop_discount)
	modifiers.fragment_reward_multiplier = clampf(modifiers.fragment_reward_multiplier, modifiers.minimum_fragment_reward_multiplier, modifiers.maximum_fragment_reward_multiplier)
	return modifiers

func snapshot_content_unlocks(profile: ProfileState, modifiers: StartingRunModifiers) -> void:
	if profile == null or modifiers == null:
		return
	for piece: PieceDefinition in profile.unlocked_pieces:
		if piece != null and not modifiers.unlocked_pieces.has(piece):
			modifiers.unlocked_pieces.append(piece)
	for relic: RelicDefinition in profile.unlocked_relics:
		if relic != null and not modifiers.unlocked_relics.has(relic):
			modifiers.unlocked_relics.append(relic)
	for enemy: EnemyDefinition in profile.unlocked_enemies:
		if enemy != null and not modifiers.unlocked_enemies.has(enemy):
			modifiers.unlocked_enemies.append(enemy)
	for event: RunEventDefinition in profile.unlocked_events:
		if event != null and not modifiers.unlocked_events.has(event):
			modifiers.unlocked_events.append(event)

func _get_projected_level(
	profile: ProfileState,
	projected_levels: Dictionary[UpgradeDefinition, int],
	upgrade: UpgradeDefinition
) -> int:
	if projected_levels.has(upgrade):
		return projected_levels[upgrade]
	return profile.get_upgrade_level(upgrade)
