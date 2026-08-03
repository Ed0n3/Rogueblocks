class_name SpecialPieceActivationResult
extends RefCounted

var status: SpecialPieceActivationStatus.Value = SpecialPieceActivationStatus.Value.UNAVAILABLE
var message: String
var candidate: PiecePlacementCandidate

func succeeded() -> bool:
	return status == SpecialPieceActivationStatus.Value.STARTED and candidate != null and candidate.found
