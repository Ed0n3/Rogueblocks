class_name BoardTileMapRenderer
extends Node2D

const BlockVisualSettings = preload("res://presentation/board/block_visual_settings.gd")

enum LayerBand {
	BACKGROUND,
	AREA,
	GRID,
	WALL,
	OCCUPIED,
	SELECTION,
	PREVIEW,
	MARKER,
}

enum TileStyle {
	SOLID,
	INSET,
	OUTLINE,
	BEVEL_SHADOW,
	BEVEL_HIGHLIGHT,
	MECHANICAL_CORNER_CUT,
	BLOCK_STYLE_TEXTURE,
	DOT,
	CROSS,
	PLUS,
	TARGET,
	EDGE_UP,
	EDGE_RIGHT,
	EDGE_DOWN,
	EDGE_LEFT,
	BOLT,
}

const TILE_SOURCE_ID: int = 0
const TILE_ATLAS_ROW: int = 0

@export_range(8, 128, 1) var tile_texture_size: int = 64
@export_range(1, 16, 1) var outline_texture_thickness: int = 1
@export_range(1, 16, 1) var edge_texture_thickness: int = 2
@export var block_visual_settings: BlockVisualSettings

class TileLayerEntry extends RefCounted:
	var band: LayerBand
	var style: TileStyle
	var color: Color
	var layer: TileMapLayer

	func _init(entry_band: LayerBand, entry_style: TileStyle, entry_color: Color, tile_layer: TileMapLayer) -> void:
		band = entry_band
		style = entry_style
		color = entry_color
		layer = tile_layer

var tile_set_resource: TileSet
var tile_layers: Array[TileLayerEntry] = []
var update_revision: int = 0
var poisoned_effect_layer: BoardStatusEffectLayer
var electrified_effect_layer: BoardStatusEffectLayer

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	poisoned_effect_layer = get_node_or_null("PoisonedBlockEffects") as BoardStatusEffectLayer
	electrified_effect_layer = get_node_or_null("ElectrifiedBlockEffects") as BoardStatusEffectLayer
	_ensure_block_visual_settings()
	_ensure_tile_set()
	_configure_effect_layers()

func set_board_transform(screen_origin: Vector2, cell_world_size: float, camera_zoom: float = 1.0) -> void:
	position = screen_origin
	var tile_scale: float = cell_world_size * camera_zoom / float(tile_texture_size)
	scale = Vector2.ONE * tile_scale

func set_tile(cell: Vector2i, band: LayerBand, style: TileStyle, color: Color) -> void:
	var layer: TileMapLayer = _get_or_create_layer(band, style, color)
	layer.set_cell(cell, TILE_SOURCE_ID, Vector2i(int(style), TILE_ATLAS_ROW))

func set_beveled_tile(cell: Vector2i, band: LayerBand, color: Color) -> void:
	_ensure_block_visual_settings()
	set_tile(cell, band, TileStyle.SOLID, color)
	set_tile(cell, band, TileStyle.OUTLINE, block_visual_settings.outline_color)
	set_tile(cell, band, TileStyle.BEVEL_SHADOW, Color(Color.BLACK, color.a * block_visual_settings.shadow_opacity))
	set_tile(cell, band, TileStyle.BEVEL_HIGHLIGHT, Color(Color.WHITE, color.a * block_visual_settings.highlight_opacity))

func set_block_tile(cell: Vector2i, band: LayerBand, color: Color) -> void:
	_ensure_block_visual_settings()
	if block_visual_settings.block_style_texture != null:
		var texture_modulate: Color = color if block_visual_settings.tint_block_style_texture else Color(1.0, 1.0, 1.0, color.a)
		set_tile(cell, band, TileStyle.BLOCK_STYLE_TEXTURE, texture_modulate)
		return
	set_beveled_tile(cell, band, color)
	set_tile(cell, band, TileStyle.MECHANICAL_CORNER_CUT, Color(block_visual_settings.outline_color, color.a * block_visual_settings.mechanical_corner_cut_opacity))

func erase_tile(cell: Vector2i, band: LayerBand, style: TileStyle, color: Color) -> void:
	var entry: TileLayerEntry = _find_layer(band, style, color)
	if entry != null:
		entry.layer.erase_cell(cell)

func clear_band(band: LayerBand) -> void:
	for entry: TileLayerEntry in tile_layers:
		if entry.band == band:
			entry.layer.clear()
	update_revision += 1

func clear_all() -> void:
	for entry: TileLayerEntry in tile_layers:
		entry.layer.clear()
	update_revision += 1

func set_status_effect_cells(poisoned_cells: Array[Vector2i], electrified_cells: Array[Vector2i]) -> void:
	if poisoned_effect_layer != null:
		poisoned_effect_layer.set_cells(poisoned_cells)
	if electrified_effect_layer != null:
		electrified_effect_layer.set_cells(electrified_cells)

func get_tile_count() -> int:
	var count: int = 0
	for entry: TileLayerEntry in tile_layers:
		count += entry.layer.get_used_cells().size()
	return count

func get_layer_count() -> int:
	return tile_layers.size()

func _get_or_create_layer(band: LayerBand, style: TileStyle, color: Color) -> TileMapLayer:
	var existing: TileLayerEntry = _find_layer(band, style, color)
	if existing != null:
		return existing.layer
	_ensure_tile_set()
	var layer: TileMapLayer = TileMapLayer.new()
	layer.name = "Tiles_%d_%d_%d" % [int(band), int(style), tile_layers.size()]
	layer.tile_set = tile_set_resource
	layer.modulate = color
	layer.z_as_relative = false
	layer.z_index = 0
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if style == TileStyle.BLOCK_STYLE_TEXTURE else CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(layer)
	var entry: TileLayerEntry = TileLayerEntry.new(band, style, color, layer)
	tile_layers.append(entry)
	_sort_layers()
	return layer

func _sort_layers() -> void:
	tile_layers.sort_custom(func(left: TileLayerEntry, right: TileLayerEntry) -> bool:
		if left.band != right.band:
			return left.band < right.band
		return left.style < right.style)
	var child_index: int = 0
	for entry: TileLayerEntry in tile_layers:
		if entry.band <= LayerBand.OCCUPIED:
			move_child(entry.layer, child_index)
			child_index += 1
	var effect_layers: Array[BoardStatusEffectLayer] = [poisoned_effect_layer, electrified_effect_layer]
	for effect_layer: BoardStatusEffectLayer in effect_layers:
		if effect_layer != null:
			move_child(effect_layer, child_index)
			child_index += 1
	for entry: TileLayerEntry in tile_layers:
		if entry.band > LayerBand.OCCUPIED:
			move_child(entry.layer, child_index)
			child_index += 1

func _find_layer(band: LayerBand, style: TileStyle, color: Color) -> TileLayerEntry:
	for entry: TileLayerEntry in tile_layers:
		if entry.band == band and entry.style == style and entry.color.is_equal_approx(color):
			return entry
	return null

func _ensure_tile_set() -> void:
	if tile_set_resource != null:
		return
	var atlas_image: Image = _create_tile_atlas()
	var atlas_texture: ImageTexture = ImageTexture.create_from_image(atlas_image)
	var atlas_source: TileSetAtlasSource = TileSetAtlasSource.new()
	atlas_source.texture = atlas_texture
	atlas_source.texture_region_size = Vector2i.ONE * tile_texture_size
	for style_index: int in TileStyle.size():
		atlas_source.create_tile(Vector2i(style_index, TILE_ATLAS_ROW))
	tile_set_resource = TileSet.new()
	tile_set_resource.tile_size = Vector2i.ONE * tile_texture_size
	tile_set_resource.add_source(atlas_source, TILE_SOURCE_ID)

func _ensure_block_visual_settings() -> void:
	if block_visual_settings == null:
		block_visual_settings = BlockVisualSettings.load_default()

func _create_tile_atlas() -> Image:
	var style_count: int = TileStyle.size()
	var atlas: Image = Image.create(tile_texture_size * style_count, tile_texture_size, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for style_index: int in style_count:
		if style_index == TileStyle.BLOCK_STYLE_TEXTURE:
			_copy_block_style_texture(atlas, style_index)
			continue
		for y: int in tile_texture_size:
			for x: int in tile_texture_size:
				if _style_contains_pixel(style_index, Vector2i(x, y)):
					atlas.set_pixel(style_index * tile_texture_size + x, y, Color.WHITE)
	return atlas

func _copy_block_style_texture(atlas: Image, style_index: int) -> void:
	if block_visual_settings.block_style_texture == null:
		return
	var source_image: Image = block_visual_settings.block_style_texture.get_image()
	if source_image == null or source_image.is_empty():
		return
	var texture_image: Image = source_image.duplicate()
	if texture_image.get_format() != Image.FORMAT_RGBA8:
		texture_image.convert(Image.FORMAT_RGBA8)
	if texture_image.get_size() != Vector2i.ONE * tile_texture_size:
		texture_image.resize(tile_texture_size, tile_texture_size, Image.INTERPOLATE_BILINEAR)
	var destination: Vector2i = Vector2i(style_index * tile_texture_size, 0)
	atlas.blit_rect(texture_image, Rect2i(Vector2i.ZERO, texture_image.get_size()), destination)

func _style_contains_pixel(style: TileStyle, pixel: Vector2i) -> bool:
	var maximum_index: int = tile_texture_size - 1
	var inset_minimum: int = 1
	var inset_maximum: int = maximum_index - 1
	var outline_maximum: int = outline_texture_thickness - 1
	var edge_maximum: int = edge_texture_thickness - 1
	match style:
		TileStyle.SOLID:
			return true
		TileStyle.INSET:
			return pixel.x >= inset_minimum and pixel.x <= inset_maximum and pixel.y >= inset_minimum and pixel.y <= inset_maximum
		TileStyle.OUTLINE:
			return pixel.x <= outline_maximum or pixel.x >= maximum_index - outline_maximum or pixel.y <= outline_maximum or pixel.y >= maximum_index - outline_maximum
		TileStyle.BEVEL_SHADOW:
			var shadow_maximum: int = maximum_index - block_visual_settings.tile_bevel_inset
			var shadow_minimum: int = maxi(block_visual_settings.tile_bevel_inset, shadow_maximum - block_visual_settings.tile_bevel_thickness + 1)
			return (pixel.x >= shadow_minimum and pixel.x <= shadow_maximum) or (pixel.y >= shadow_minimum and pixel.y <= shadow_maximum)
		TileStyle.BEVEL_HIGHLIGHT:
			var highlight_minimum: int = block_visual_settings.tile_bevel_inset
			var highlight_maximum: int = mini(maximum_index - block_visual_settings.tile_bevel_inset, highlight_minimum + block_visual_settings.tile_bevel_thickness - 1)
			return (pixel.x >= highlight_minimum and pixel.x <= highlight_maximum) or (pixel.y >= highlight_minimum and pixel.y <= highlight_maximum)
		TileStyle.MECHANICAL_CORNER_CUT:
			var corner_size: int = maxi(1, roundi(float(tile_texture_size) * block_visual_settings.mechanical_corner_cut_ratio))
			var left_distance: int = pixel.x
			var right_distance: int = maximum_index - pixel.x
			var top_distance: int = pixel.y
			var bottom_distance: int = maximum_index - pixel.y
			return left_distance + top_distance < corner_size or right_distance + top_distance < corner_size or right_distance + bottom_distance < corner_size or left_distance + bottom_distance < corner_size
		TileStyle.DOT:
			var center: Vector2 = Vector2.ONE * float(maximum_index) * 0.5
			return Vector2(pixel).distance_to(center) <= maxf(1.0, float(tile_texture_size) * 0.12)
		TileStyle.CROSS:
			return absi(pixel.x - pixel.y) <= 1 or absi(pixel.x + pixel.y - maximum_index) <= 1
		TileStyle.PLUS:
			var middle: int = tile_texture_size / 2
			return absi(pixel.x - middle) <= 1 or absi(pixel.y - middle) <= 1
		TileStyle.TARGET:
			var target_center: Vector2 = Vector2.ONE * float(maximum_index) * 0.5
			var target_radius: float = float(tile_texture_size) * 0.27
			return absf(Vector2(pixel).distance_to(target_center) - target_radius) <= 0.85
		TileStyle.EDGE_UP:
			return pixel.y <= edge_maximum
		TileStyle.EDGE_RIGHT:
			return pixel.x >= maximum_index - edge_maximum
		TileStyle.EDGE_DOWN:
			return pixel.y >= maximum_index - edge_maximum
		TileStyle.EDGE_LEFT:
			return pixel.x <= edge_maximum
		TileStyle.BOLT:
			var normalized: Vector2 = Vector2(pixel) / float(maximum_index)
			var upper: bool = normalized.y < 0.5 and normalized.x >= 0.42 - normalized.y * 0.36 and normalized.x <= 0.62 - normalized.y * 0.12
			var lower: bool = normalized.y >= 0.5 and normalized.x >= 0.38 + (normalized.y - 0.5) * 0.12 and normalized.x <= 0.58 + (normalized.y - 0.5) * 0.36
			var bridge: bool = normalized.x >= 0.32 and normalized.x <= 0.68 and normalized.y >= 0.43 and normalized.y <= 0.57
			return upper or lower or bridge
	return false

func _configure_effect_layers() -> void:
	for layer: BoardStatusEffectLayer in [poisoned_effect_layer, electrified_effect_layer]:
		if layer != null:
			layer.set_tile_size(float(tile_texture_size))
