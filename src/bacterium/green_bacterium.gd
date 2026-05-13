class_name GreenBacterium
extends Bacterium

var chained_to: Entity = null

@export var dash_attack_radius: int = 120

# <> method section <>
func _ready():
	super()
	
	# set personal parameters
	bacterium_name = "Green Bacterium"
	behavior_state = StateMachine.get_start_green_bacterium_state();
	
	set_parameters_for_day()

func _physics_process(delta: float):
	super(delta)

func set_parameters_for_day():
	acceleration = 0
	dash_acceleration = 0
	
	attack_radius = 0
	dash_attack_radius = 0
	luring_radius = 0
	view_distance = 0

func set_parameters_for_night():
	acceleration = 0
	dash_acceleration = 20
	
	attack_radius = 50
	dash_attack_radius = 120
	luring_radius = 140
	view_distance = 160

# <> states algorithms <>
func photosynthesizing():
	if _priming.try_process(0.5, "PHOTOSYNTHESIZING") == false:
		return
	
	const PHOTOSYNTHES_ENERGY: int = 1
	var value = can_consume_energy(PHOTOSYNTHES_ENERGY)
	consume_energy(value)

## Generate [EnergyCell] with the fixed impulse and throw in random direction
func shedding():
	if not is_ready_to_shedding():
		return
	
	if _priming.try_process(2, "SHEDDING") == false:
		return
	
	# impulse
	const MIN_IMPULSE: int = 40; const MAX_IMPULSE: int = 60
	var impulse: float = _random.randi_range(MIN_IMPULSE, MAX_IMPULSE)
	var rotated_impulse: Vector2 = Vector2(impulse, 0.0).rotated(_random.randf_range(-PI, PI))
	
	# energy
	const MIN_CELL_ENERGY: int = 15; const MAX_CELL_ENERGY:  int = 20
	var energy_value: int = _random.randi_range(MIN_CELL_ENERGY, MAX_CELL_ENERGY)
	var cell_energy: int  = can_spend_energy(energy_value)
	spend_energy(cell_energy)
	
	# apply parameters and create new energy_cell
	WorldContext.energy_shed.emit(self.global_position, rotated_impulse, cell_energy)

func vampirism(prey: Bacterium):
	if not is_instance_valid(chained_to):
		chained_to = null
		return
	
	# replace self closer to a prey
	const LERP_WEIGHT: float = 0.5
	set_nav_target(prey.position)
	var direction: Vector2 = get_nav_target() - self.position
	var lerp_to = get_nav_target() - (direction.normalized() * 45)	# fix collision troubles
	position = lerp(position, lerp_to, LERP_WEIGHT)
	rotation = lerp_angle(rotation, direction.angle(), LERP_WEIGHT)
	
	# _priming to vampirism
	if _priming.try_process(0.1, "VAMPIRISM") == false:
		return
	
	const VAMPIRISM_POWER: int = 1 	# per action tick
	var distance: float = direction.length()
	if distance < attack_radius:
		var can_be_took     = prey.can_spend_energy(VAMPIRISM_POWER)
		var can_be_consumed = self.can_consume_energy(can_be_took)
		prey.spend_energy(can_be_consumed)
		self.consume_energy(can_be_consumed)
		
		# check did the prey die
		if prey.energy <= 0:
			chained_to = null

func hunting():
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if (object is PurpleBacterium):
				return Enums.RelationshipTypes.PREY
		elif object is EnergyCell:
			return Enums.RelationshipTypes.LURE	# green bacteria can't eat energy cells
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	nearby_objects = get_nearby_objects(view_distance, identification_rules)
	
	var prey_record: InfoPack = InfoUtils.get_nearest_prey(self.position, nearby_objects)
	_choice_hunting_action(prey_record)

## Decide what kind action must be used if nearby environment full of objects.
func _choice_hunting_action(prey_record: InfoPack):
	if prey_record.is_not_empty():
		var prey: Entity = prey_record.object
		
		var direction_to_prey: Vector2 = prey.position - self.position
		var distance: float = direction_to_prey.length()
		
		if distance < dash_attack_radius:
			set_nav_target(prey_record.object.position)
			intercept_target(get_nav_target(), prey_record.object.velocity)
		elif distance < luring_radius:
			var is_nearby_lure: bool = InfoUtils.is_lure_nearby(nearby_objects)
			if is_nearby_lure == false:
				const THROWING_FORCE: float = 80
				throw_lure_to(direction_to_prey, THROWING_FORCE)
