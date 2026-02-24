class_name Bacteria
extends CharacterBody2D

# speed-up paramenters (pixel/sec)
const SPEED_UP_MOD: float = 10.0	# todo: rename to "acceleration" 
const COLLISION_DEFLECTION: float = 20.0
const DECELERATION_MOD: float = 0.5
const MAX_SPEED: float = 200.0
const SLOW_DOWN_RADIUS: float = 100.0	# use deceleration if the object to close to the target

const FOV: float = PI / 4
const ROTATION_WEIGHT: float = 0.03

var random = RandomNumberGenerator.new()

var type: Enums.BacteriaType
var nav_field: Vector2	# area from (xy = 0) to (xy = nav_field.xy) pixels

var view_direction_angle: float = 0.0

# <> Methods section <>
func _ready():
	random.randomize()		# todo: add correct random generation
	_set_random_type()
	position = generate_smart_point()

func _process(delta: float):
	$ViewDirection.rotate(view_direction_angle - $ViewDirection.rotation)
	
func _physics_process(delta: float):
	_deceleration()
	_find_target()
	_rotate_and_force()
	
	# speed limit
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	move_and_slide()

# <> "set" methods <>
func _set_random_type():
	const BACTERIAS_ORIGIN_TYPES = 3	# todo: add special file with all prop constants
	var _type = Enums.BacteriaType
	match randi_range(0, BACTERIAS_ORIGIN_TYPES):
		0: type = _type.Green;  modulate = Color.LAWN_GREEN
		1: type = _type.Purple; modulate = Color.MEDIUM_PURPLE
		2: type = _type.Orange; modulate = Color.DARK_ORANGE
		_: type = _type.Default

func set_navigation_field(field: Vector2):
	nav_field = field

# <> Other methods <>
func generate_smart_point() -> Vector2:	# generate point inside navigation area
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
		nav_agent.target_position = generate_smart_point()

func _rotate_and_force():
	var target = ($NavigationAgent.target_position - position)
	var view_target = target - velocity # how to need rotate for come to the target with the fastest way
	
	# add acceleration if the target inside the FOV area
	if view_target.angle_to(target) < (FOV / 2):
		velocity += Vector2.RIGHT.rotated(view_direction_angle) * SPEED_UP_MOD
	# rotate a face to the target
	view_direction_angle = lerp_angle(view_direction_angle, view_target.angle(), ROTATION_WEIGHT)
	

func _speed_up():	# old method
	velocity += Vector2.RIGHT.rotated(view_direction_angle) * SPEED_UP_MOD

func _rotate_to_target(target_angle: float): # old method
	view_direction_angle = lerp_angle(view_direction_angle, target_angle, 0.1)


#func set_interception_course():
	#var target = $NavigationAgent.target_position
	#
	#var angle = velocity.angle_to(target)
	#var intercept = Vector2.ZERO
	#if angle > 0:
		#intercept = velocity.rotated(angle * -2)
	#if angle < 0:
		#intercept = velocity.rotated(angle * 2)



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

#func navigation_movement():
	#
	#var nav_agent = $NavigationAgent
	#if nav_agent.is_navigation_finished():
		#$NavigationAgent.target_position = generate_smart_point()
	#else:
		## calculate velocity
		#var next_pos = nav_agent.get_next_path_position()
		#var direction = global_position.direction_to(next_pos)
		
		#velocity += direction.normalized() * SPEED_UP_MOD
		
		#var adjustment = Vector2.ZERO
		#var angle = velocity.angle_to(direction)
		#if angle > 0:
			#adjustment = velocity.normalized() * (-2 * angle) * SPEED_UP_MOD
