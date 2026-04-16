class_name Observer
extends Camera2D

@export var max_zoom: float = 2.0
@export var min_zoom: float = 0.2
@export var delta_zoom: float = 0.1

var _movement_direction: Vector2 = Vector2.ZERO
var _expected_zoom: float = 1.0

# <> methods section <>
func _ready() -> void:
	make_current()

func _process(_delta: float) -> void:
	check_input()
	update_position()
	update_offset()
	update_zoom()

func update_position():
	const CAM_REPLACEMENT_SPEED: float = 20
	var delta_position = _movement_direction / zoom * CAM_REPLACEMENT_SPEED
	position += delta_position
	
func update_offset():
	const OFFSET_WEIGHT: float = 0.08
	const LERP_WEIGHT: float = 0.2
	
	var to = get_global_mouse_position() - get_screen_center_position()
	var expected_offset = to * OFFSET_WEIGHT
	offset = lerp(offset, expected_offset, LERP_WEIGHT)

func update_zoom():
	var WEIGHT: float = 0.15
	zoom.x = lerp(zoom.x, _expected_zoom, WEIGHT)
	zoom.y = lerp(zoom.y, _expected_zoom, WEIGHT)

func change_expected_zoom(_delta_zoom: float):
	_expected_zoom = clampf(_expected_zoom + _delta_zoom, min_zoom, max_zoom)

func check_input():
	# camera replacement
	_movement_direction = Vector2.ZERO
	if Input.is_action_pressed("cam_move_up"):		_movement_direction.y -= 1
	if Input.is_action_pressed("cam_move_down"):	_movement_direction.y += 1
	if Input.is_action_pressed("cam_move_left"):	_movement_direction.x -= 1
	if Input.is_action_pressed("cam_move_right"):	_movement_direction.x += 1
	
	# camera zoom
	if Input.is_action_just_pressed("cam_zoom_in"):
		change_expected_zoom(delta_zoom)
	elif Input.is_action_just_pressed("cam_zoom_out"):
		change_expected_zoom(-delta_zoom)
