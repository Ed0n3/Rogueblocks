class_name PiecePoolChangeResult
extends RefCounted

enum Reason { NONE, UNKNOWN_PIECE, SOURCE_ADDED, POOL_FULL, PIECE_ADDED, NOT_ACTIVE, MINIMUM_POOL, PIECE_REMOVED, INVALID_SELECTION }

var changed: bool = false
var card: PieceCardState
var piece: PieceDefinition
var source_relic: RelicDefinition
var reason: Reason = Reason.NONE
var pool_size: int = 0
