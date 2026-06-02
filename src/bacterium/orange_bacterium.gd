class_name OrangeBacterium
extends Bacterium

@export var warning_radius: int = 95
@export var is_stealth_mode_on: bool = false

@onready var dash_timer: Timer = $DashTimer
@onready var cooldown_timer: Timer = $CooldownTimer

# <> method section <>
func _ready():
	super()	# set default parameters
	
	# set personal parameters
	bacterium_name = "Orange Bacterium"
	behavior_state = StateMachine.get_start_orange_bacterium_state();
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	
	set_parameters_for_day()

func _physics_process(delta: float):
	super(delta)

func set_physics_updating(enable: bool):
	dash_timer.paused = not enable
	cooldown_timer.paused = not enable
	super(enable)

func set_parameters_for_day():
	acceleration = 3
	dash_acceleration = 40
	
	attack_radius  = 60
	warning_radius = 0
	luring_radius  = 0
	view_distance  = 240

func set_parameters_for_night():
	acceleration = 8
	dash_acceleration = 8
	
	attack_radius  = 0
	warning_radius = 70
	luring_radius  = 120
	view_distance  = 120

func get_info() -> String:
	var information: String = super()
	information += "dash active: %.1f/%.1f\n" % [dash_timer.time_left, dash_timer.wait_time]
	information += "dash cooldown: %.1f/%.1f\n" % [cooldown_timer.time_left, cooldown_timer.wait_time]
	return information

## Override method to realize stealth mode.
func can_be_identified() -> bool:
	return not is_stealth_mode_on

func _dash(_acceleration: float):
	if not dash_timer.is_stopped():
		super(dash_acceleration)
	else:
		super(acceleration)	# default dash

func stealth_mode_on():
	is_stealth_mode_on = true
	modulate.a = 0.2

func stealth_mode_off():
	is_stealth_mode_on = false
	modulate.a = 1.0

func try_activate_power_dash():
	# activate power-dash if cooldown finished
	if cooldown_timer.is_stopped():
		if dash_timer.is_stopped():
			dash_timer.start()

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
		if (object is PurpleBacterium):
			return Enums.RelationshipTypes.PREDATOR
		elif (object is EnergyCell):
			return Enums.RelationshipTypes.LURE
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	nearby_objects = get_nearby_objects(view_distance, identification_rules)
	
	# choice action
	var predator_record: InfoPack = InfoUtils.get_nearest_predator(self.position, nearby_objects)
	_choice_hiding_action(predator_record)

func _choice_hiding_action(predator_record: InfoPack):
	if predator_record.is_not_empty():
		var predator: Bacterium = predator_record.object
		
		var direction = predator.position - self.position
		var distance = direction.length()
		if distance < luring_radius:
			const THROWING_FORCE: float = 260.0
			throw_lure_to(direction, THROWING_FORCE)
	# else: just wait

func hunting():
	stealth_mode_off()
	
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if (object is GreenBacterium) or (object is PurpleBacterium):
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
		if distance < view_distance:
			try_activate_power_dash()
			intercept_target(get_nav_target(), prey_record.object.velocity)
	else:
		patrol()	# default

# <> signals section <>
func _on_dash_timer_timeout():
	cooldown_timer.start()
