class_name Bacterium
extends CharacterBody2D

signal energy_shed(global_position: Vector2, impulse: float, energy: int)

# object parameters
# > speed - pixel/sec
const ACCELERATION: float = 30.0
const MAX_SPEED: float = 400.0
const FOV: float = PI / 3
const HIGTER_ENERGY_LIMIT = 100
const OVERAGE_ENERGY_LIMIT = 90

# changeable object parameters
var bacterium_name: String = "Unknown"
var type: Enums.BacteriumTypes
var energy: int = 0
var view_direction_angle: float = 0.0
var behavior_state: RefCounted
var debug_layer: int

# technical
var _nav_field: Vector2	# area from (xy = 0) to (xy = nav_field.xy) pixels
var _random: RandomNumberGenerator = RandomNumberGenerator.new()
var _physics_frame: int = 0
var _selected_with_mouse: bool = false

# <> Methods section <>
func _ready():
	_random.randomize()
	_set_random_type()
	position = _generate_smart_point()

func _process(delta: float):
	$ViewDirection.rotate(view_direction_angle - $ViewDirection.rotation)

func _physics_process(delta: float):
	_physics_frame += 1
	
	const UPDATE_INTERVAL = 2
	if _physics_frame % UPDATE_INTERVAL == 0:
		behavior_state.apply(self)
	
	if _selected_with_mouse == true:
		velocity = Vector2.ZERO
		global_position = lerp(global_position, get_global_mouse_position(), 10 * delta)
	
	# todo: replace the next block into state
	_deceleration()
	#_find_target()
	#_rotate_and_force()
	
	# speed limit
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	move_and_slide()

# <> "set" methods <>
func _set_random_type():
	const BACTERIA_ORIGIN_TYPES = 3	# todo: add special file with all prop constants
	match 0:	# todo: add real generation "randi_range(0, BACTERIA_ORIGIN_TYPES)"
		0:
			bacterium_name = "Green Bacterium"
			type = Enums.BacteriumTypes.GREEN
			modulate = Color.LAWN_GREEN
			behavior_state = StateMachine.get_start_green_bacterium_state()	# todo: add behavior for every bacteria types
		1: 
			type = Enums.BacteriumTypes.PURPLE
			modulate = Color.MEDIUM_PURPLE
		2: 
			type = Enums.BacteriumTypes.ORANGE
			modulate = Color.DARK_ORANGE

func set_navigation_field(field: Vector2):
	_nav_field = field

# <> need for identification "get" methods <>
func get_bacterium_type() -> Enums.BacteriumTypes:
	return type

func get_pos() -> Vector2:
	return position

# <> Other methods <>
func adjust_energy(energy: int) -> int:
	const MAX_ENERGY: int = 100
	const MIN_ENERGY: int = 0
	energy = clamp(self.energy, MIN_ENERGY, MAX_ENERGY)
	self.energy = energy
	return energy	# return how much was added or removed

func _generate_smart_point() -> Vector2:	# generate point inside navigation area
	#generate random point inside nav_polygon
	var point = Vector2(
		_random.randf_range(0, _nav_field.x),
		_random.randf_range(0, _nav_field.y)
	)
	# get target pos inside navigation area
	var area = get_world_2d().get_navigation_map()
	var nearest_point = NavigationServer2D.map_get_closest_point(area, point)
	return point

## NOT RELEVANT
func _find_target():
	var nav_agent = $NavigationAgent
	if nav_agent.is_navigation_finished():
		nav_agent.target_position = _generate_smart_point()

func _rotate_to_target(target_local_pos: Vector2):
	$NavigationAgent.target_position = target_local_pos	# save target
	var to_target = $NavigationAgent.target_position * 100 # multiply is need to make dash harder
	var view_target = to_target - velocity # how to need rotate for come to the target with the fastest way
	
	const ROTATION_WEIGHT: float = 0.1
	view_direction_angle = lerp_angle(view_direction_angle, view_target.angle(), ROTATION_WEIGHT)

## [pray] parameter must be [Bacterium] or [EnergyCell]
func try_rotate_to_pray(own_dash_power: float, pray: Variant) -> bool:
	var target: Vector2 = pray.position - position
	var target_in_future = target.normalized() * own_dash_power + pray.velocity # how to need rotate to dash to the target with the fastest way
	_rotate_to_target(target_in_future)
	
	var view_direction = Vector2.RIGHT.rotated(view_direction_angle)
	if abs(view_direction.angle_to(target_in_future)) < (FOV / 8):
		return true
	return false

func dash(dash_power: float):
	velocity += Vector2.RIGHT.rotated(view_direction_angle) * dash_power

## [object] can be Bacterium or EnergyCell
func smart_dash(dash_power: float, pray: Variant):
	var is_rotated: bool = try_rotate_to_pray(dash_power, pray)
	if is_rotated == true:
		dash(dash_power)

## NOT RELEVAT
func _rotate_and_force():
	var target = ($NavigationAgent.target_position - position)
	var view_target = target - velocity # how to need rotate for come to the target with the fastest way
	
	# add acceleration if the target inside the FOV area
	if view_target.angle_to(target) < (FOV / 2):
		velocity += Vector2.RIGHT.rotated(view_direction_angle) * ACCELERATION
	# turn to face to the target
	const ROTATION_WEIGHT: float = 0.03
	view_direction_angle = lerp_angle(view_direction_angle, view_target.angle(), ROTATION_WEIGHT)

func _deceleration():
	const DECELERATION_MOD: float = 6.0
	if velocity.length() > DECELERATION_MOD:
		velocity -= velocity.normalized() * DECELERATION_MOD
	else:
		velocity = Vector2.ZERO

func _collision_fluence():
	const COLLISION_DEFLECTION: float = 20.0
	var collider
	if get_slide_collision_count() > 0:
		collider = get_slide_collision(0)
	if collider:
		velocity += collider.get_normal() * (COLLISION_DEFLECTION)

func nearby_objects(area_radius: float) -> Array:
	const RAYS_COUNT: int = 32
	var objects_in_area: Array = []
	var space_state = get_world_2d().direct_space_state
	
	# use raycast to findind nearby objects
	Debug.remove_layer(debug_layer)
	debug_layer = Debug.get_new_layer()
	for i in range(0, RAYS_COUNT):
		var ray_rotation = (PI * 2) / RAYS_COUNT * i
		var target = global_position + Vector2.RIGHT.rotated(ray_rotation) * area_radius
		
		var query = PhysicsRayQueryParameters2D.create(global_position, target)
		query.collision_mask = 6 # 2 and 3
		query.exclude = [get_rid()]
		
		var result = space_state.intersect_ray(query)
		if result:
			var collider = result.collider
			if collider is CharacterBody2D:
				objects_in_area.push_back(collider)
				#print("Find: ", collider.name)
		
		Debug.add_line(
			debug_layer,
			global_position,
			target,
			Enums.DEBUG_OBJECT_COLORS[Enums.ObjectTypes.NONE]
		)
	
	return objects_in_area

func photosynthesing():
	if energy + 1 <= HIGTER_ENERGY_LIMIT:
		energy += 1

func shedding(impulse: float):
	const MIN_ENERGY: int = 25
	const MAX_ENERGY: int = 35
	var cell_energy: int = _random.randi_range(MIN_ENERGY, MAX_ENERGY) * -1
	var can_be_used_energy = self.adjust_energy(cell_energy)
	energy_shed.emit(global_position, impulse, can_be_used_energy)

func vampirism(pray: Variant):
	const VAMPIRISM_RADIUS: int = 40
	const VAMPIRISM_POWER: int = 1 	# per behavior tick
	const LERP_WEIGHT: float = 0.1
	
	var distance: Vector2 = pray.global_position - global_position
	if distance.length() > VAMPIRISM_RADIUS:
		global_position = global_position.lerp(pray.global_position, LERP_WEIGHT)
	else:
		var can_be_consumed = pray.adjust_energy(-VAMPIRISM_POWER)
		self.adjust_energy(can_be_consumed)

## If no lure is nearby, throw one
func try_throw_lure(impulse: float, nearby_objects: Array[InfoPack]):
	var cell_pack: InfoPack = InfoUtils.get_nearest_energy_cell(nearby_objects)
	if cell_pack.object_type == Enums.ObjectTypes.NONE:
		shedding(impulse)

# <> other <>
func _on_clickable_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		# print info about the obj
		if event.pressed:
			Singlton.bacterium_clicked.emit(self)
		
		# move the obj
		if Input.is_action_pressed("move_object"):
			_selected_with_mouse = true
		else: _selected_with_mouse = false
