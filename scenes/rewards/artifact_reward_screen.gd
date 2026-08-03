class_name ArtifactRewardScreen
extends Control

const BOSS_ARTIFACTS_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/bosses/artifacts.tres")

signal artifact_selected()
signal reward_changed(data: Dictionary)

const CARD_SCENE: PackedScene = preload("res://presentation/artifacts/artifact_reward_card.tscn")

var run_state: RunState
var rewards: Array[BossArtifactDefinition] = []
var boss: EnemyDefinition
var act: int = 0
var reward_committed: bool = false
var viewed_artifacts: Array[BossArtifactDefinition] = []

func start(current_run: RunState, defeated_boss: EnemyDefinition, completed_act: int) -> void:
	run_state = current_run
	boss = defeated_boss
	act = completed_act
	var rules: GameRules = load("res://content/rules/default_game_rules.tres") as GameRules
	rewards = ArtifactRewardGenerator.new().generate(run_state, boss, act, rules.boss_artifact_offer_count)
	_display_rewards()
	_register_tutorial_target()

func restore(current_run: RunState, data: Dictionary) -> bool:
	run_state = current_run
	var boss_reference: String = String(data.get("boss", data.get("boss_id", "")))
	boss = ContentReferenceCodec.decode_legacy(boss_reference, EnemyDefinition, ContentRegistry.catalog) as EnemyDefinition
	if boss == null:
		return false
	act = maxi(0, int(data.get("act", 0)))
	for value: Variant in data.get("artifacts", data.get("artifact_ids", [])) as Array:
		var definition: BossArtifactDefinition = ContentReferenceCodec.decode_legacy(String(value), BossArtifactDefinition, ContentRegistry.catalog) as BossArtifactDefinition
		if definition == null:
			return false
		rewards.append(definition)
	_display_rewards()
	_register_tutorial_target()
	return not rewards.is_empty()

func _display_rewards() -> void:
	for child: Node in %Cards.get_children():
		%Cards.remove_child(child)
		child.queue_free()
	for index: int in rewards.size():
		var card: ArtifactRewardCard = CARD_SCENE.instantiate() as ArtifactRewardCard
		%Cards.add_child(card)
		card.setup(rewards[index])
		card.mouse_entered.connect(_mark_artifact_viewed.bind(rewards[index]))
		card.focus_entered.connect(_mark_artifact_viewed.bind(rewards[index]))
		card.button_down.connect(_mark_artifact_viewed.bind(rewards[index]))
		card.pressed.connect(_select_reward.bind(index))
		MotionPresets.pop_in(card, 0.07 * float(index), MotionSettings.from_saved_settings(SaveService.settings))
	%Summary.text = "ACT %d BOSS DEFEATED\nChoose one Artifact" % (act + 1)

func _select_reward(index: int) -> void:
	if reward_committed or index < 0 or index >= rewards.size():
		return
	if TutorialService.active_definition == BOSS_ARTIFACTS_TUTORIAL and viewed_artifacts.size() < rewards.size():
		%Confirmation.text = "READ ALL %d ARTIFACTS BEFORE CHOOSING  |  %d / %d" % [rewards.size(), viewed_artifacts.size(), rewards.size()]
		return
	if not run_state.add_artifact(rewards[index], act):
		return
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.ARTIFACT_OBTAINED)
	event.artifact = rewards[index]
	TutorialService.publish_event(event)
	reward_committed = true
	%Confirmation.text = "%s ADDED TO THIS RUN" % rewards[index].display_name.to_upper()
	for card: ArtifactRewardCard in %Cards.get_children():
		card.disabled = true
	reward_changed.emit(to_save_data())
	var tween: Tween = create_tween()
	tween.tween_interval(0.65)
	tween.tween_callback(func() -> void: artifact_selected.emit())

func to_save_data() -> Dictionary:
	var serialized_artifacts: Array[String] = []
	for definition: BossArtifactDefinition in rewards:
		serialized_artifacts.append(ContentReferenceCodec.encode(definition))
	return {"artifacts": serialized_artifacts, "boss": ContentReferenceCodec.encode(boss), "act": act, "selected": reward_committed}

func _register_tutorial_target() -> void:
	TutorialService.enter_screen(TutorialScreen.Value.ARTIFACT, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.ARTIFACT_FIRST_CARD, %Cards, self)
	TutorialService.publish(TutorialEventId.Value.ARTIFACT_REWARD_SCREEN_OPENED)
	if not tree_exiting.is_connected(_unregister_tutorial_target):
		tree_exiting.connect(_unregister_tutorial_target)

func _unregister_tutorial_target() -> void:
	TutorialService.leave_screen(TutorialScreen.Value.ARTIFACT, self)
	TutorialTargetRegistry.unregister_owner(self)

func _mark_artifact_viewed(artifact: BossArtifactDefinition) -> void:
	if not viewed_artifacts.has(artifact):
		viewed_artifacts.append(artifact)
	if viewed_artifacts.size() == rewards.size():
		%Confirmation.text = "ALL ARTIFACTS READ  |  CHOOSE ONE"
