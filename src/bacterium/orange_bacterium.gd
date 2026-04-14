class_name OrangeBacterium
extends Bacterium

@export var power_dash_acceleration: float = 30
@export var warning_radius: int = 95
@export var is_stealth_mode_on: bool = false

@onready var dash_timer: Timer = $DashTimer
@onready var cooldown_timer: Timer = $CooldownTimer

# <> method section <>
func _ready():
	super()	# set default parameters
	
	# override var's
	bacterium_name = "Orange Bacterium"
	modulate = Color.ORANGE				# todo: change on texture
	behavior_state = StateMachine.get_start_orange_bacterium_state();
	
	# set personal action radii
	view_distance = 160
	luring_radius = 150
	attack_radius = 45
	
	acceleration = 3
	dash_timer.timeout.connect(_on_dash_timer_timeout)

func _physics_process(delta: float):
	super(delta)

## Override method to realize stealth mode.
func can_be_identified() -> bool:
	return not is_stealth_mode_on

func _dash(_acceleration: float):
	if not dash_timer.is_stopped():
		super(power_dash_acceleration)
	else:
		super(acceleration)	# default dash

func stealth_mode_on():
	is_stealth_mode_on = true
	modulate.a = 0.2

func stealth_mode_off():
	is_stealth_mode_on = false
	modulate.a = 1.0

# <> behavior methods section <>
## Analyse environment for predators and check are they so close.
func should_swim_away() -> bool:
	var predator_record = InfoUtils.get_nearest_predator(self.position, nearby_objects)
	if predator_record.is_not_empty():
		var distance = (predator_record.object.position - self.position).length()
		if distance < warning_radius:
			return true
	return false

func swim_away(enemy_detection_radius: float):
	# scan environment on predators
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if (object is PurpleBacterium) or (object is GreenBacterium):
			return Enums.RelationshipTypes.PREDATOR
		return Enums.RelationshipTypes.NONE	# default
	
	nearby_objects = get_nearby_objects(enemy_detection_radius, identification_rules)
	super(enemy_detection_radius)	# default swim away instuction

func hiding():
	stealth_mode_on()
	
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if (object is PurpleBacterium) or (object is GreenBacterium):
			return Enums.RelationshipTypes.PREDATOR
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	nearby_objects = get_nearby_objects(view_distance, identification_rules)
	
	# choice action
	var predator_record: InfoPack = InfoUtils.get_nearest_predator(self.position, nearby_objects)
	_choice_hiding_action(predator_record)

func _choice_hiding_action(predator_record: InfoPack):
	if predator_record.is_not_empty():
		var predator: Entity = predator_record.object
		
		var direction = predator.position - self.position
		var distance = direction.length()
		if distance < luring_radius:
			const THROWING_FORCE: float = 260.0
			throw_lure_to(direction, THROWING_FORCE)
	# else: just wait

func hunting():
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if (object is PurpleBacterium) or (object is EnergyCell):
			return Enums.RelationshipTypes.PREY
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	nearby_objects = get_nearby_objects(view_distance, identification_rules)
	
	var prey_record: InfoPack = InfoUtils.get_nearest_prey(self.position, nearby_objects)
	_choice_hunting_action(prey_record)

## Decide what kind action must be used if nearby environment full of objects.
func _choice_hunting_action(prey_record: InfoPack):
	# choice action
	if prey_record.is_not_empty():
		set_nav_target(prey_record.object.position)	# save last target pos
		
		var distance: float = (prey_record.object.position - self.position).length()
		if distance < attack_radius:
			bite_target(prey_record.object)
		elif distance < view_distance:
			if cooldown_timer.is_stopped():	# activate power-dash if cooldown timeout
				dash_timer.start(3)
			intercept_target(get_nav_target(), prey_record.object.velocity)
	else:
		patrol()	# default

# <> signals section <>
func _on_dash_timer_timeout():
	cooldown_timer.start(4)
