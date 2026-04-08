class_name OrangeBacterium
extends Bacterium

var is_power_dash_activated: bool = false
var power_dash_acceleration: float = 2000
@onready var cooldown = $ActionCooldown

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
		if cooldown.is_stopped():
			super(power_dash_acceleration)
			cooldown.try_cooldown(5, "POWER_DASH_COOLDOWN")
			return
	super(acceleration)	# default deceleration
	
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
	if prey_record.is_not_empty():
		set_nav_target(prey_record.object.position)
		
		var distance: float = (prey_record.object.position - self.position).length()
		if distance < attack_radius:
			bite_target(prey_record.object)
		if distance < view_distance:
			is_power_dash_activated = true
			intercept_target(get_nav_target(), prey_record.object.velocity)
			is_power_dash_activated = false
	else:
		patrol()	# default
