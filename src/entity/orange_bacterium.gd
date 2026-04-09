class_name OrangeBacterium
extends Bacterium

var is_power_dash_activated: bool = false
var power_dash_acceleration: float = 3000
var is_power_dash_active = false
@onready var dash_timer = $DashTimer

# <> method section <>
func _ready():
	super()	# set default parameters
	
	# override var's
	bacterium_name = "Orange Bacterium"
	modulate = Color.ORANGE				# todo: change on texture
	behavior_state = StateMachine.get_start_orange_bacterium_state();
	
	# set personal action radii
	view_distance = 160
	luring_radius = 140
	attack_radius = 45

func _physics_process(delta: float):
	super(delta)

func _dash(_acceleration: float):
	if is_power_dash_activated == true:
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

func dash_target(target: Entity):
	if is_power_dash_active == true:
		dash_timer.try_process(2, "POWER_DASH")
		intercept_target(target.position, target.velocity)
	else:
		dash_timer.try_process(1.2, "COOLDOWN")
		reach_target(target.position)

## Decide what kind action must be used if nearby environment full of objects.
func _choice_hunting_action(prey_record: InfoPack):
	
	if dash_timer.is_stopped():
		if is_power_dash_active:
			is_power_dash_active = false
		else:
			is_power_dash_active = true
	
	if prey_record.is_not_empty():
		set_nav_target(prey_record.object.position)
		
		var distance: float = (prey_record.object.position - self.position).length()
		if distance < attack_radius:
			bite_target(prey_record.object)
		if distance < view_distance:
			dash_target(prey_record.object)
	else:
		patrol()	# default
