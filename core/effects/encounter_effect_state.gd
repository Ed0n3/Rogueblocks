class_name EncounterEffectState
extends RefCounted

var enemy_health: int = 0
var enemy_maximum_health: int = 1
var enemy_shield: int = 0
var player_shield: int = 0
var enemy_countdown: int = 1
var enemy_base_interval: int = 1
var player_statuses: StatusCollection = StatusCollection.new()
var enemy_statuses: StatusCollection = StatusCollection.new()
