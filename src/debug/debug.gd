# Singlton "Debug" for... debug features :/
extends Node2D

enum DEBUG_MODES {
	OFF,
	SINGLE,
	FULL
}

var debug_mode = DEBUG_MODES.SINGLE;
var line_width: float = 2.0

var _last_id: int = 0;
var _layers: Dictionary[int, Array] = {}
var _selected_object: Entity = null

# <> methods <>
func _ready() -> void:
	Singlton.click_on_object.connect(_on_click_on_object)
	Singlton.remove_object.connect(_on_remove_object)
	
	z_index = -1
	
	# ignore shadow
	var unshaded_material = CanvasItemMaterial.new()
	unshaded_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = unshaded_material

func _process(_delta: float):
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
	for line in _layers.get(layer):
		draw_line(line.start, line.end, line.color, line_width)

func draw_all():
	for record in _layers:
		for line in _layers.get(record):
			draw_line(line.start, line.end, line.color, line_width)

func add_line(layer_id: int, start: Vector2, end: Vector2, color: Color):
	_layers.get(layer_id).append(
		Line.new(start, end, color)
	)

func get_new_layer() -> int:
	_last_id += 1
	var lines: Array[Line] = []
	_layers[_last_id] = lines
	return _last_id

func clean_layer(id: int):
	_layers[id] = []

func remove_layer(id: int):
	if _layers.has(id):
		_layers[id] = []
		_layers.erase(id)

# <> signals <>
func _on_click_on_object(object: CharacterBody2D):
	if object is Bacterium:
		_selected_object = object

func _on_remove_object(entity: Entity):
	if entity == _selected_object:
		_selected_object = null
