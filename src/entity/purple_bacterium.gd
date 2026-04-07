class_name PurpleBacterium
extends Bacterium

# <> method section <>
func _ready():
	super()	# set default parameters
	
	# override var's
	bacterium_name = "Purple Bacterium"
	modulate = Color.PURPLE				# todo: change on texture
	behavior_state = StateMachine.get_start_purple_bacterium_state();

	# todo: set personal action radii

func _physics_process(delta: float):
	super(delta)

# <> behaviour dependencies <>
func swim_away(enemy_detection_radius: float):
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if Singlton.is_day():
			if object is OrangeBacterium:
				return Enums.RelationshipTypes.PREDATOR
		else: # if night is comming
			if object is GreenBacterium:
				return Enums.RelationshipTypes.PREDATOR
		return Enums.RelationshipTypes.NONE	# default
	
	nearby_objects = get_nearby_objects(enemy_detection_radius, identification_rules)
	super(enemy_detection_radius)	# default swim away instuction

func cell_finding():
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if object is OrangeBacterium:
			return Enums.RelationshipTypes.PREDATOR
		elif object is EnergyCell:
			return Enums.RelationshipTypes.PREY
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	nearby_objects = get_nearby_objects(view_distance, identification_rules)
	
	# find a nearest food
	var food_record: InfoPack = InfoUtils.get_nearest_energy_cell(nearby_objects)
	_choice_hunting_action(food_record)

func hunting():
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if object is OrangeBacterium:
			return Enums.RelationshipTypes.PREY
		elif object is GreenBacterium:
			return Enums.RelationshipTypes.PREDATOR
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	nearby_objects = get_nearby_objects(view_distance, identification_rules)
	
	## find a nearest food
	var prey_record: InfoPack = InfoUtils.get_nearest_prey(nearby_objects)
	_choice_hunting_action(prey_record)

func _choice_hunting_action(target_record: InfoPack):
	if target_record.is_not_empty():
		var distance: float = (target_record.object.position - position).length()
		
		if distance < view_distance:
			# intercept target
			set_nav_target(target_record.object.position)
			intercept_target(get_nav_target(), target_record.object.velocity)
			
		if distance < attack_radius:
			bite_target(target_record.object)
	else:
		patrol() # continue find target
