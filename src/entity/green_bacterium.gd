class_name GreenBacterium
extends Bacterium

var chained_to: Entity = null

# <> method section <>
func _ready():
	super()
	
	# override var's
	bacterium_name = "Green Bacterium"
	modulate = Color.LAWN_GREEN			# todo: change on texture
	behavior_state = StateMachine.get_start_green_bacterium_state();
	
	# todo: set personal action radii

func _physics_process(delta: float):
	super(delta)

# <> states algorithms <>
func photosynthesizing():
	if priming.try_process(0.2, "PHOTOSYNTHESIZING") == false:
		return
	
	const PHOTOSYNTHES_ENERGY: int = 1
	var value = can_consume_energy(PHOTOSYNTHES_ENERGY)
	consume_energy(value)

## Generate [EnergyCell] with the fixed impulse
func shedding():
	if energy < energy_level_shading:
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

func vampirism(prey: Bacterium):
	if chained_to == null:
		return
	
	# replace self closer to a prey
	const LERP_WEIGHT: float = 0.5
	var distance: Vector2 = prey.global_position - self.global_position
	var lerp_to = global_position + distance - (distance.normalized() * 32)	# fix collision troubles
	global_position = lerp(global_position, lerp_to, LERP_WEIGHT)
	rotation = lerp_angle(rotation, distance.angle(), LERP_WEIGHT)
	
	# priming to vampirism
	if priming.try_process(0.15, "VAMPIRISM") == false:
		return
	
	#const VAMPIRISM_RADIUS: int = 60	# todo: replace this area into enums
	const VAMPIRISM_POWER: int = 1 	# per action tick
	if distance.length() < attack_radius:
		var can_be_took     = prey.can_spend_energy(VAMPIRISM_POWER)
		var can_be_consumed = self.can_consume_energy(can_be_took)
		prey.spend_energy(can_be_consumed)
		self.consume_energy(can_be_consumed)
		
		# check did the prey die
		if prey.energy == 0:
			chained_to = null

func hunting():
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if object is Bacterium:
			if object is GreenBacterium:
				return Enums.RelationshipTypes.NEUTRAL
			else: return Enums.RelationshipTypes.PREY	# anyway other bacteria is prey
		elif object is EnergyCell:
			return Enums.RelationshipTypes.CELL	# green bacteria can't eat energy cells
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	nearby_objects = get_nearby_objects(view_distance, identification_rules)
	
	var prey_record: InfoPack = InfoUtils.get_nearest_prey(nearby_objects)
	if prey_record.is_not_empty():
		_choice_hunting_action(prey_record)

## Decide what kind action must be used if nearby environment full of objects.
func _choice_hunting_action(prey_info: InfoPack):
	var distance: float = (prey_info.object.position - position).length()
	if distance < dash_attack_radius:
		intercept_target(prey_info.object.position, prey_info.object.velocity)
	elif distance < luring_radius:
		var is_nearby_lure: bool = InfoUtils.is_lure_nearby(nearby_objects)
		if (is_nearby_lure == false):
			const LURE_IMPULSE: float = 100
			throw_lure(LURE_IMPULSE)
