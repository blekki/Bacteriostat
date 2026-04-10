class_name Bacterium
extends Entity

# basic parameters
# > movement - pixel/physic_frame
@export var acceleration: float = 10.0
@export var max_speed: float = 600.0
@export var FOV: float = PI / 3

# energy levels
@export var energy_level_death: int = min_energy
@export var energy_level_luring: int = 35
@export var energy_level_shedding: int = 85
@export var energy_level_fission: int = 95

# action radii
@export var attack_radius: int = 45
@export var luring_radius: int = 140
@export var view_distance: int = 160

# changeable object parameters
var bacterium_name: String = "Bacterium"
var behavior_state: RefCounted = StateMachine.waiting_state	# default
var nearby_objects: Array[InfoPack] = []	# save identified nearby objects [object, relationship]
@onready var priming: ActionPriming = $ActionPriming	# todo: make the same to nav_agent

# technical
var _physics_frame: int = 0
var nav_field: Vector2 = Vector2.ZERO # area from (xy = 0) to (xy = nav_field.xy) pixels
var _random: RandomNumberGenerator = RandomNumberGenerator.new()

# <> Methods section <>
func _init():
	super()	# set default parameters
	_random.randomize()

func _ready():
	max_energy = 100
	energy = 90
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
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

func _generate_smart_point() -> Vector2:	# todo: generate point inside navigation area
	# generate random point
	var point = Vector2(
		_random.randf_range(0, nav_field.x),
		_random.randf_range(0, nav_field.y)
	)
	return point

## safe behavior changing
func change_state_to(new_state: RefCounted):
	Debug.clean_layer(debug_layer)
	behavior_state = new_state

# <> is ready to ... <>
func is_ready_to_luring() -> bool:
	return energy >= energy_level_luring

func is_ready_to_shedding() -> bool:
	return energy >= energy_level_shedding

func is_ready_to_fission() -> bool:
	return energy >= energy_level_fission

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

## Rotate and get result [is_rotated_to].
func try_rotate_to(target_pos: Vector2) -> bool:
	const ROTATION_WEIGHT: float = 0.075
	var target_angle = (target_pos - position).angle()
	rotation = lerp_angle(rotation, target_angle, ROTATION_WEIGHT)
	
	var field_of_dash = (FOV / 6)
	if abs(angle_difference(rotation, target_angle)) < field_of_dash:
		return true	# rotation finished
	return false	# need to continue rotate

func dash_to(target_pos: Vector2):
	var is_rotated: bool = try_rotate_to(target_pos)
	if is_rotated == true:
		_dash(acceleration)

## Use to "delicate" reaching a target. An object comes to and stops on a target. Need to simple patrol or to similar action.
func reach_target(target_pos: Vector2):
	# deceleretion leveling (algorithm requirement)
	if velocity.length() > 0:
		velocity += velocity.normalized() * PASSIVE_DECELERATION
	
	var anchor_point = target_pos - velocity
	dash_to(anchor_point)

## Use to "rough" reaching a target. An object comes across a target. Can be used to attack somebody or run away.
func intercept_target(target_pos: Vector2, target_velocity: Vector2):
	var to_target = target_pos - self.position + target_velocity
	var dash_direction = abs(velocity.angle_to(to_target))
	
	var anchor_point = Vector2.ZERO
	if (dash_direction < PI / 18.0) or (velocity.length() < 10):
		anchor_point = self.position + to_target.normalized()	# dash to a target
	else:
		anchor_point = target_pos - (velocity * 2)	# change trajectory
	dash_to(anchor_point)

func patrol():
	if is_target_reached():
		generate_new_nav_target()
	else:
		var target = get_nav_target() 
		reach_target(target)

# <> states algorithms <>
## Return objects inside area.
func scan_environment(area_radius: float) -> Array[Entity]:
	const RAYS_COUNT: int = 32
	var objects_in_area: Array[Entity] = []
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

func get_nearby_objects(area_radius: float, identification_rules: Callable) -> Array[InfoPack]:
	# init var's
	var unknown_objects = scan_environment(area_radius)	# can be EnergyCells or Bacteria
	var identified_objects: Array[InfoPack] = []
	
	# identification
	for object in unknown_objects:
		var relationship: Enums.RelationshipTypes = Enums.RelationshipTypes.NONE
		relationship = identification_rules.call(object)
		
		identified_objects.push_back(
			InfoPack.new(object, relationship)
		)
		
		# DEBUG:
		Debug.add_line(
			self.debug_layer,
			self.position,
			object.position,
			Enums.DEBUG_RELATIONSHIP_COLORS[relationship]
		)
	return identified_objects

func fission():
	if not is_ready_to_fission():
		return
	
	if priming.try_process(3, "FISSION") == false:
		return
	
	var child_energy: int = roundi(energy / 2.0)
	spend_energy(child_energy)
	Singlton.fission.emit(self)

func bite_target(prey: Entity):
	var distance_to_target = (prey.position - self.position).length()
	if distance_to_target >= attack_radius:
		return	# prey is to far away
	
	if priming.try_process(0.2, "BITE") == false:
		return
	
	const BITE_POWER: int = 30
	var can_be_took 	= prey.can_spend_energy(BITE_POWER)
	var can_be_consumed = self.can_consume_energy(can_be_took)
	prey.spend_energy(can_be_consumed)
	self.consume_energy(can_be_consumed)

func hunting():
	# instruction is personalized to the every bacterium type
	pass

func swim_away(_enemy_detection_radius: float):
	var predator_record: InfoPack = InfoUtils.get_nearest_predator(nearby_objects)
	if predator_record.is_not_empty():
		var predator = predator_record.object
		
		const ESCAPE_DISTANCE: float = 140
		var direction_out_predator = (self.position - predator.position).normalized()
		var swim_to = self.position + direction_out_predator * ESCAPE_DISTANCE
		
		# swim out the predator with the best escape path (considering predator velocity)
		set_nav_target(swim_to)
		intercept_target(get_nav_target(), predator_record.object.velocity * -1)

## Generate lure [EnergyCell] with a custom impulse
func throw_lure_to(direction: Vector2, throw_power: float):
	if not is_ready_to_luring():
		return	# not enough energy
	
	if priming.try_process(1.4, "THROW LURE") == false:
		return
	
	# impulse
	var accuracy_offset = _random.randf_range(-PI / 4.0, PI / 4.0)
	var impulse = direction.rotated(accuracy_offset).normalized() * throw_power
	
	# energy
	const MIN_LURE_ENERGY:  int = 8;
	const MAX_LURE_ENERGY:  int = 12;
	var energy_value: int = _random.randi_range(MIN_LURE_ENERGY, MAX_LURE_ENERGY)
	var cell_energy: int = can_spend_energy(energy_value)
	spend_energy(cell_energy)
	
	# create lure
	Singlton.energy_shed.emit(self.global_position, impulse, cell_energy)
