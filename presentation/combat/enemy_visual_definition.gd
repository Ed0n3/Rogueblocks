class_name EnemyVisualDefinition
extends Resource

enum AttackVisualStyle { MELEE, PROJECTILE, BOARD_EFFECT }
enum DeathVisualStyle { DISSOLVE, FRAGMENT, FADE }

@export var sprite: Texture2D
@export var sprite_scale: float = 1.0
@export var sprite_offset: Vector2 = Vector2.ZERO
@export var pivot_ratio: Vector2 = Vector2(0.5, 0.82)
@export var shadow_size: Vector2 = Vector2(170.0, 34.0)
@export var shadow_offset: Vector2 = Vector2(0.0, 14.0)
@export var accent_color: Color = Color("c58bff")
@export var hit_color: Color = Color("e9edfa")
@export var attack_color: Color = Color("ff786f")
@export var idle_height: float = 6.0
@export var idle_duration: float = 1.8
@export var idle_rotation_degrees: float = 1.0
@export var recoil_distance: float = 18.0
@export var lunge_distance: float = 34.0
@export var shake_strength: float = 5.0
@export var attack_style: AttackVisualStyle = AttackVisualStyle.MELEE
@export var death_style: DeathVisualStyle = DeathVisualStyle.DISSOLVE
