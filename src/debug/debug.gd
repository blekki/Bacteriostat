# Singlton "Debug" for... debug features :/
extends Node2D

const IS_DEBUG_MODE_ON = true
const LINE_WIDTH: float = 2.0

var last_id: int = 0;
var layers: Dictionary[int, Array] = {}

# <> methods <>
func _ready() -> void:
	z_index = -10

func _process(delta: float):
	if IS_DEBUG_MODE_ON == true:
		queue_redraw()

func _draw():
	for id in layers:
		for line in layers.get(id):
			draw_line(line.start, line.end, line.color, LINE_WIDTH)

func get_new_layer() -> int:
	last_id += 1
	var lines: Array[Line] = []
	layers[last_id] = lines
	return last_id

func add_line(layer_id: int, start: Vector2, end: Vector2, color: Color):
	layers.get(layer_id).append(
		Line.new(start, end, color)
	)

func clean_layer(id: int):
	layers[id] = []

func remove_layer(id: int):
	if layers.has(id):
		layers.erase(id)
