class_name Bacterium		# todo: rename to "Bacterium"
extends CharacterBody2D

# Paramenters
# > speed - pixel/sec
# > rotation - radian/sec
const ACCELERATION: float = 10.0
const MAX_SPEED: float = 200.0
const DECELERATION_MOD: float = 0.5
const COLLISION_DEFLECTION: float = 20.0
const FOV: float = PI / 3
const ROTATION_WEIGHT: float = 0.03
const ENERGY_LIMIT = 100

# object parameters
var type: Enums.BacteriaTypes
var energy: int = 0
var view_direction_angle: float = 0.0

var behavior_state: RefCounted

# techical
var nav_field: Vector2	# area from (xy = 0) to (xy = nav_field.xy) pixels
var random = RandomNumberGenerator.new()

# <> Methods section <>
func _ready():
	random.randomize()
	_set_random_type()
	position = _generate_smart_point()

func _process(delta: float):
	$ViewDirection.rotate(view_direction_angle - $ViewDirection.rotation)
	
func _physics_process(delta: float):
	behavior_state.update(self)		# errors: fix state changer
	behavior_state.do_task(self)
	
	_deceleration()
	_find_target()
	_rotate_and_force()
	
	# speed limit
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	move_and_slide()

# <> "set" methods <>
func _set_random_type():
	const BACTERIA_ORIGIN_TYPES = 3	# todo: add special file with all prop constants
	match 0:	# todo: add real generation "randi_range(0, BACTERIA_ORIGIN_TYPES)"
		0:
			type = Enums.BacteriaTypes.Green
			modulate = Color.LAWN_GREEN
			behavior_state = StateMachine.get_start_green_bacterium_state()	# todo: add behavior for every bacteria types
		1: 
			type = Enums.BacteriaTypes.Purple
			modulate = Color.MEDIUM_PURPLE
		2: 
			type = Enums.BacteriaTypes.Orange
			modulate = Color.DARK_ORANGE

func set_navigation_field(field: Vector2):
	nav_field = field

# <> Other methods <>
func _generate_smart_point() -> Vector2:	# generate point inside navigation area
	#generate random point inside nav_polygon
	var point = Vector2(
		random.randf_range(0, nav_field.x),
		random.randf_range(0, nav_field.y)
	)
	# get target pos inside navigation area
	var area = get_world_2d().get_navigation_map()
	var nearest_point = NavigationServer2D.map_get_closest_point(area, point)
	return point

func _find_target():
	var nav_agent = $NavigationAgent
	if nav_agent.is_navigation_finished():
		nav_agent.target_position = _generate_smart_point()

func _rotate_and_force():
	var target = ($NavigationAgent.target_position - position)
	var view_target = target - velocity # how to need rotate for come to the target with the fastest way
	
	# add acceleration if the target inside the FOV area
	if view_target.angle_to(target) < (FOV / 2):
		velocity += Vector2.RIGHT.rotated(view_direction_angle) * ACCELERATION
	# turn to face to the target
	view_direction_angle = lerp_angle(view_direction_angle, view_target.angle(), ROTATION_WEIGHT)

func _deceleration():
	if velocity.length() > DECELERATION_MOD:
		velocity -= velocity.normalized() * DECELERATION_MOD
	else:
		velocity = Vector2.ZERO

func collision_fluence():
	var collision = get_slide_collision(0)
	if collision:
		var collider = collision.get_collider()		# todo: fix unsync fluence
		velocity += collision.get_normal() * (COLLISION_DEFLECTION)

func photosynthesing():
	if energy + 1 <= ENERGY_LIMIT:
		energy += 1
	print("energy: ", energy)

func recycle_energy():
	if energy - 5 >= 0:
		energy -= 5
	print("energy: ", energy)
