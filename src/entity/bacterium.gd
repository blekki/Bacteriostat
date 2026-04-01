class_name Bacterium
extends Entity

# object parameters
# > speed - pixel/sec
const ACCELERATION: float = 10.0	# todo: rewrite ACCEELRATION into variable
const MAX_SPEED: float = 600.00
const FOV: float = PI / 3
const HIGTER_ENERGY_LIMIT = 100
const OVERAGE_ENERGY_LIMIT = 90

enum EnergyLimit {
	DEATH = _MIN_ENERGY,	# default value = 0
	LURING = 35,
	SHADING = 90,
	FISSION = 95,
	MAX = 100,
}

# changeable object parameters
var bacterium_name: String = "Unknown Bacterium"
var type: Enums.BacteriumTypes
var behavior_state: RefCounted
var chained_to: Entity = null
@onready var priming = $ActionPriming	# todo: make the same to nav_agent
# todo: add nearby_objects var

# technical
var _physics_frame: int = 0
var _nav_field: Vector2 = Vector2.ZERO # area from (xy = 0) to (xy = nav_field.xy) pixels
var _random: RandomNumberGenerator = RandomNumberGenerator.new()

# <> Methods section <>
func _init():
	super()	# set default parameters
	_random.randomize()
	_max_energy = 100
	energy = 90 # 40

func _ready():
	#_set_random_type()	# todo: replace into _init
	position = _generate_smart_point()

func _physics_process(delta: float) -> void:
	behavior_state.do_task(self)
	
	const STATE_UPDATE_INTERVAL = 2
	if _physics_frame >= STATE_UPDATE_INTERVAL:
		behavior_state.try_update_behavior(self)
		_physics_frame = 0
	else: _physics_frame += 1
	
	_limit_speed()
	super(delta)	# use also default physics parameters

func _limit_speed():
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

func _generate_smart_point() -> Vector2:	# todo: generate point inside navigation area
	# generate random point
	var point = Vector2(
		_random.randf_range(0, _nav_field.x),
		_random.randf_range(0, _nav_field.y)
	)
	return point

## safe behavior changing
func change_state_to(new_state: RefCounted):
	Debug.clean_layer(debug_layer)
	behavior_state = new_state

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

func set_navigation_field(field: Vector2):	# todo: remove
	_nav_field = field

# <> identification methods
func get_obj_name() -> String:
	return bacterium_name

func get_bacterium_type() -> Enums.BacteriumTypes:	# need for identification
	return type

# <> for movement <>
func is_target_reached() -> bool:
	return $NavigationAgent.is_navigation_finished()

func set_nav_target(target_pos: Vector2):	# todo: rename into "_set_nav_target"
	$NavigationAgent.target_position = target_pos

func get_nav_target() -> Vector2:
	return $NavigationAgent.target_position

func generate_new_nav_target():
	var target = _generate_smart_point()
	set_nav_target(target)

func _dash(impulse: float):
	velocity += Vector2.RIGHT.rotated(rotation) * impulse

func try_rotate_to(target_pos: Vector2) -> bool:
	var target_rotation = (target_pos - position).angle()
	const ROTATION_WEIGHT: float = 0.075
	rotation = lerp_angle(rotation, target_rotation, ROTATION_WEIGHT)
	
	var field_of_dash = (FOV / 6)
	if abs(angle_difference(rotation, target_rotation)) < field_of_dash:
		return true	# rotation finished
	return false	# need to continue rotate

func dash_to(target_pos: Vector2):
	var is_rotated: bool = try_rotate_to(target_pos)
	if is_rotated == true:
		_dash(ACCELERATION)
	
## Use to "delicate" reaching a target. An object comes to and stops on a target. Need to simple patrol or the same.
func reach_target(target_pos: Vector2):
	# todo: save target_pos into NavigationAgent
	
	# deceleretion leveling (algorithm requirement)
	if velocity.length() > 0:
		velocity += velocity.normalized() * PASSIVE_DECELERATION
	
	var anchor_point = target_pos - velocity
	dash_to(anchor_point)

## Use to "rough" reaching a target. An object comes across a target. Can be used to attack somebody or run away.
func intercept_target(target_pos: Vector2, target_velocity: Vector2):
	# todo: save target_pos into NavigationAgent
	var to_target = target_pos - self.position + target_velocity
	var dash_direction = abs(velocity.angle_to(to_target))
	
	var anchor_point = Vector2.ZERO
	if (dash_direction < PI / 36.0) or (velocity.length() < 10):
		anchor_point = self.position + to_target.normalized()	# dash to a target
	else:
		anchor_point = target_pos - (velocity * 2)	# change trajectory
	dash_to(anchor_point)
	
# <> states requirement <>
## Result: Array[Variant] can contains Bacteria and EnergyCells
func get_nearby_objects(area_radius: float) -> Array[Variant]:
	const RAYS_COUNT: int = 32
	var objects_in_area: Array = []
	var space_state = get_world_2d().direct_space_state
	
	# use raycast to findind nearby objects
	Debug.clean_layer(debug_layer)
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
		
		# save line parameters to debug printing
		Debug.add_line(
			debug_layer,
			global_position,
			target,
			Enums.DEBUG_RELATIONSHIP_COLORS[Enums.RelationshipTypes.NONE]
		)
	
	return objects_in_area

func photosynthesizing():
	if priming.try_process(0.2, "PHOTOSYNTHESIZING") == false:
		return
	
	const PHOTOSYNTHES_ENERGY: int = 1
	var value = can_consume_energy(PHOTOSYNTHES_ENERGY)
	consume_energy(value)

## Generate [EnergyCell] with a fixed impulse
func shedding():
	if energy < EnergyLimit.SHADING:
		return
	
	if priming.try_process(2, "SHEDDING") == false:
		return
	
	const MIN_CELL_ENERGY: int = 15; const MAX_CELL_ENERGY:  int = 20
	const MIN_IMPULSE: int = 40;     const MAX_IMPULSE: int = 60
	var energy_value: int = _random.randi_range(MIN_CELL_ENERGY, MAX_CELL_ENERGY)
	var impulse: float    = _random.randi_range(MIN_IMPULSE, MAX_IMPULSE)
	var cell_energy: int  = can_spend_energy(energy_value)
	spend_energy(cell_energy)
	Singlton.energy_shed.emit(self.global_position, impulse, cell_energy)

func fission():
	if energy < EnergyLimit.FISSION:
		return
	
	if priming.try_process(3, "FISSION") == false:
		return
	
	var child_energy: int = roundi(energy / 2.0)
	spend_energy(child_energy)
	Singlton.fission.emit(self)

func vampirism(pray: Entity):
	if chained_to == null:
		return
	
	# replace self closer to a pray
	const LERP_WEIGHT: float = 0.5
	var distance: Vector2 = pray.global_position - self.global_position
	var lerp_to = global_position + distance - (distance.normalized() * 32)	# fix collision troubles
	global_position = lerp(global_position, lerp_to, LERP_WEIGHT)
	rotation = lerp_angle(rotation, distance.angle(), LERP_WEIGHT)
	
	# priming to vampirism
	if priming.try_process(0.15, "VAMPIRISM") == false:
		return
	
	const VAMPIRISM_RADIUS: int = 60	# todo: replace this area into enums
	const VAMPIRISM_POWER: int = 1 	# per action tick
	if distance.length() < VAMPIRISM_RADIUS:
		var can_be_took     = pray.can_spend_energy(VAMPIRISM_POWER)
		var can_be_consumed = self.can_consume_energy(can_be_took)
		pray.spend_energy(can_be_consumed)
		self.consume_energy(can_be_consumed)
		
		# check did the pray die
		if pray.energy == 0:
			chained_to = null

func is_ready_luring() -> bool:
	var is_ready = energy >= EnergyLimit.LURING
	return is_ready

func bite_target(pray: Entity):
	if priming.try_process(0.2, "BITE") == false:
		return
	
	const BITE_POWER: int = 30
	var can_be_took 	= pray.can_spend_energy(BITE_POWER)
	var can_be_consumed = self.can_consume_energy(can_be_took)
	pray.spend_energy(can_be_consumed)
	self.consume_energy(can_be_consumed)

## Generate lure [EnergyCell] with a custom impulse
func throw_lure(impulse: float):
	if priming.try_process(1.4, "THROW LURE") == false:
		return
	
	const MIN_LURE_ENERGY:  int = 10;
	const MAX_LURE_ENERGY:  int = 20;
	var energy_value: int = _random.randi_range(MIN_LURE_ENERGY, MAX_LURE_ENERGY)
	var cell_energy: int = self.can_consume_energy(energy_value)
	self.spend_energy(cell_energy)
	Singlton.energy_shed.emit(self.global_position, impulse, cell_energy)
