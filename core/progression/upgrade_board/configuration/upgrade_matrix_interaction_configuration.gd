class_name UpgradeMatrixInteractionConfiguration
extends Resource

## Rendered size of one Matrix cell before camera scaling.
@export_range(1.0, 64.0, 0.5) var cell_pixel_size: float = 12.0
## Smallest allowed Matrix camera zoom.
@export_range(0.05, 4.0, 0.05) var minimum_zoom: float = 0.2
## Largest allowed Matrix camera zoom.
@export_range(0.1, 12.0, 0.1) var maximum_zoom: float = 4.0
## Camera zoom used when focusing an upgrade region.
@export_range(0.1, 12.0, 0.1) var region_focus_zoom: float = 1.35
## Multiplicative zoom step used by mouse wheel and zoom buttons.
@export_range(1.01, 2.0, 0.01) var mouse_wheel_zoom_factor: float = 1.14
## Scale applied to trackpad pan gesture deltas.
@export_range(0.1, 10.0, 0.1) var trackpad_pan_multiplier: float = 2.0
## Screen-space padding retained while clamping the Matrix camera.
@export_range(0.0, 256.0, 1.0) var camera_edge_padding: float = 56.0
## Pointer travel required before a press becomes a drag.
@export_range(0.0, 64.0, 1.0) var drag_start_distance: float = 8.0
## Minimum distance between two touches before pinch scaling is evaluated.
@export_range(0.1, 64.0, 0.1) var minimum_pinch_distance: float = 4.0
## Camera interpolation speed toward its target transform.
@export_range(1.0, 40.0, 0.5) var camera_smoothing_speed: float = 18.0
## Touch travel required to choose horizontal reserve scrolling.
@export_range(0.0, 64.0, 1.0) var reserve_scroll_direction_threshold: float = 12.0
## Swipe travel required to rotate the active placement.
@export_range(16.0, 160.0, 1.0) var rotation_swipe_distance: float = 56.0
## Extra cell-size ratio accepted when hit-testing a placement preview.
@export_range(0.0, 1.0, 0.01) var preview_hit_padding_ratio: float = 0.45
