class_name TutorialRuntimeState
extends RefCounted

var tutorial: TutorialDefinition
var step_index: int = 0
var phase: TutorialRuntimePhase.Value = TutorialRuntimePhase.Value.INACTIVE
var elapsed_in_step: float = 0.0
var replay: bool = false
var screen: TutorialScreen.Value = TutorialScreen.Value.NONE
var run_sequence: int = 0
var encounter_sequence: int = -1

func to_save_data() -> Dictionary:
	return {"tutorial": ContentReferenceCodec.encode(tutorial), "step_index": step_index, "phase": int(phase), "elapsed_in_step": elapsed_in_step, "replay": replay, "screen": int(screen), "run_sequence": run_sequence, "encounter_sequence": encounter_sequence}

static func from_save_data(data: Dictionary) -> TutorialRuntimeState:
	var state: TutorialRuntimeState = TutorialRuntimeState.new()
	state.tutorial = ContentReferenceCodec.decode_legacy(String(data.get("tutorial", data.get("tutorial_id", ""))), TutorialDefinition, ContentRegistry.catalog) as TutorialDefinition
	state.step_index = maxi(0, int(data.get("step_index", 0)))
	state.phase = clampi(int(data.get("phase", TutorialRuntimePhase.Value.INACTIVE)), TutorialRuntimePhase.Value.INACTIVE, TutorialRuntimePhase.Value.FAILED) as TutorialRuntimePhase.Value
	state.elapsed_in_step = maxf(0.0, float(data.get("elapsed_in_step", 0.0)))
	state.replay = bool(data.get("replay", false))
	state.screen = int(data.get("screen", TutorialScreen.from_legacy(StringName(String(data.get("screen_id", "")))))) as TutorialScreen.Value
	state.run_sequence = int(data.get("run_sequence", String(data.get("run_id", "")).hash()))
	state.encounter_sequence = int(data.get("encounter_sequence", String(data.get("encounter_id", "")).hash()))
	return state
