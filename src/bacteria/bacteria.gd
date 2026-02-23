class_name Bacteria
extends CharacterBody2D

# speed-up paramenters (pixel/sec)
const SPEED_UP_MOD: float = 100.0
const COLLISION_DEFLECTION: float = 20.0
const DECELERATION_MOD: float = 0.5

var type: Enums.BacteriaType
var navigation_field: Vector2

# Methods section
func _ready():
	_set_random_type()

func _physics_process(delta: float):
	deceleration()
	collision_fluence()
	move_and_slide()
	# todo: add finding way and movement calculation

func _set_random_type():
	const BACTERIAS_ORIGIN_TYPES = 3
	var _type = Enums.BacteriaType
	match randi_range(0, BACTERIAS_ORIGIN_TYPES):
		0: type = _type.Green
		1: type = _type.Purple
		2: type = _type.Orange
		_: type = _type.Default
	_set_color()

func _set_color():
	var _type = Enums.BacteriaType
	match type:
		_type.Green:  modulate = Color.LAWN_GREEN
		_type.Purple: modulate = Color.MEDIUM_PURPLE
		_type.Orange: modulate = Color.DARK_ORANGE

func set_navigation_field(field: Vector2):
	navigation_field = field

func set_random_pos(range: Vector2):
	global_position.x = randf_range(0, range.x)
	global_position.y = randf_range(0, range.y)

func deceleration():
	if velocity.length() > DECELERATION_MOD:
		velocity -= velocity.normalized() * DECELERATION_MOD
	else:
		velocity = Vector2.ZERO

func collision_fluence():
	var collision = get_slide_collision(0)
	if collision:
		var collider = collision.get_collider()		# todo: fix unsync fluence
		velocity += collision.get_normal() * (COLLISION_DEFLECTION)
