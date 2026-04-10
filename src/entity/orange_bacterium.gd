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

func _dash(_acceleration: float):
	if not dash_timer.is_stopped():
		super(power_dash_acceleration)
	else:
		super(acceleration)	# default dash

# <> behavior methods section <>
func hunting():
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if (object is PurpleBacterium) or (object is EnergyCell):
			return Enums.RelationshipTypes.PREY
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	nearby_objects = get_nearby_objects(view_distance, identification_rules)
	
	var prey_record: InfoPack = InfoUtils.get_nearest_prey(nearby_objects)
	_choice_hunting_action(prey_record)

## Decide what kind action must be used if nearby environment full of objects.
func _choice_hunting_action(prey_record: InfoPack):
	# choice action
	if prey_record.is_not_empty():
		set_nav_target(prey_record.object.position)
		var distance: float = (prey_record.object.position - self.position).length()
		if distance < attack_radius:
			bite_target(prey_record.object)
		if distance < view_distance:
			if cooldown_timer.is_stopped():	# activate power-dash if cooldown timeout
				dash_timer.start(3)
			intercept_target(get_nav_target(), prey_record.object.velocity)
	else:
		patrol()	# default

func _on_dash_timer_timeout():
	cooldown_timer.start(4)
