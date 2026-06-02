# Singleton "Debug" for... debug features :/
extends Node2D

class LinesPack:
	extends RefCounted
	var lines: Array[Vector2] = []
	var colors: Array[Color] = []

enum DEBUG_MODES {
	OFF,
	SINGLE,
	FULL
}

var debug_mode = DEBUG_MODES.SINGLE;
var line_width: float = 2.0

var _last_id: int = 0
var _layers: Dictionary[int, LinesPack] = {}	# Dictionary[id, Array[lines, colors]]
var _selected_object: Entity = null
var _canvas: RID

# <> methods <>
func _ready() -> void:
	WorldContext.click_on_object_debug.connect(_on_click_on_object_debug)
	WorldContext.remove_object.connect(_on_remove_object)
	
	_canvas = RenderingServer.canvas_item_create()
	var current_canvas: RID = get_viewport().find_world_2d().canvas
	RenderingServer.canvas_item_set_parent(_canvas, current_canvas)
	RenderingServer.canvas_item_set_z_index(_canvas, 10)
	
	# ignore shadow
	var unshaded_material = CanvasItemMaterial.new()
	unshaded_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = unshaded_material
	RenderingServer.canvas_item_set_material(_canvas, material)

func _exit_tree():
	RenderingServer.free_rid(_canvas)

func _process(_delta: float):
	RenderingServer.canvas_item_clear(_canvas)
	queue_redraw()

func _input(event: InputEvent):
	if event.is_action_pressed("debug_off"):
		debug_mode = DEBUG_MODES.OFF
	elif event.is_action_pressed("debug_single_mode"):
		debug_mode = DEBUG_MODES.SINGLE
	elif event.is_action_pressed("debug_full_mode"):
		debug_mode = DEBUG_MODES.FULL

func _draw():
	match debug_mode:
		DEBUG_MODES.SINGLE:
			if _selected_object != null:
				draw_record(_selected_object.debug_layer)
		DEBUG_MODES.FULL:
			draw_all()

func draw_record(layer: int):
	if not _layers[layer].lines.is_empty():
		RenderingServer.canvas_item_add_multiline(
			_canvas, _layers[layer].lines, _layers[layer].colors, line_width
		)

func draw_all():
	for layer in _layers:
		if not _layers[layer].lines.is_empty():
			RenderingServer.canvas_item_add_multiline(
				_canvas, _layers[layer].lines, _layers[layer].colors, line_width
			)

func add_line(layer_id: int, start: Vector2, end: Vector2, color: Color):
	_layers[layer_id].lines.append(start)
	_layers[layer_id].lines.append(end)
	_layers[layer_id].colors.append(color)

func add_target(layer_id: int, target_position: Vector2, color: Color):
	const TARGET_SIZE: int = 12
	var start: Vector2
	var end: Vector2
	
	# save line 1
	start = Vector2(target_position.x, target_position.y - TARGET_SIZE)
	end   = Vector2(target_position.x, target_position.y + TARGET_SIZE)
	add_line(layer_id, start, end, color)
	# save line 2
	start = Vector2(target_position.x - TARGET_SIZE, target_position.y)
	end   = Vector2(target_position.x + TARGET_SIZE, target_position.y)
	add_line(layer_id, start, end, color)

func get_new_layer() -> int:
	_last_id += 1
	var pack: LinesPack = LinesPack.new()
	_layers[_last_id] = pack
	return _last_id

func clean_layer(id: int):
	_layers[id] = LinesPack.new()

func remove_layer(id: int):
	if _layers.has(id):
		_layers.erase(id)

# <> signals <>
func _on_click_on_object_debug(object: CharacterBody2D):
	if object is Bacterium:
		_selected_object = object

func _on_remove_object(entity: Entity):
	if entity == _selected_object:
		_selected_object = null
