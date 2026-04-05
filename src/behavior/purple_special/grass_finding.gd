# Purple bacterium special state
class_name GrassFindingState	# rename into "CellFinding"
extends RefCounted

static var name: String = "Grass finding"

enum ActionRadii {
	BITE = 40,
	DETECTION = 100,
}

# <> method section <>
static func do_task(bacterium: Bacterium):
	Debug.clean_layer(bacterium.debug_layer)
	_grass_finding(bacterium)

static func try_update_behavior(bacterium: Bacterium):
	if bacterium.energy >= bacterium.EnergyLimit.FISSION:
		bacterium.change_state_to(StateMachine.fission_state)
	
	# should "swim" away
	var is_predator_nearby: bool = InfoUtils.is_predator_nearby(bacterium.nearby_objects)
	if is_predator_nearby == true:
		bacterium.change_state_to(StateMachine.swim_away)

static func _grass_finding(bacterium: Bacterium):
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if object is OrangeBacterium:
			return Enums.RelationshipTypes.PREDATOR
		elif object is EnergyCell:
			return Enums.RelationshipTypes.EDIBLE
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	bacterium.nearby_objects = bacterium.get_nearby_objects(ActionRadii.DETECTION, identification_rules)
	
	# find a nearest food
	var food_record: InfoPack = InfoUtils.get_nearest_energy_cell(bacterium.nearby_objects)
	if food_record.object != null:
		_choice_action(bacterium, food_record)
	else: # continue find target
		change_place(bacterium)

static func change_place(bacterium: Bacterium):
	# continue find
	if bacterium.is_target_reached():
		bacterium.generate_new_nav_target()
	else:
		var target = bacterium.get_nav_target() 
		bacterium.reach_target(target)

static func _choice_action(bacterium: Bacterium, food_record: InfoPack):
	var distance: float = (food_record.object.position - bacterium.position).length()
	
	if distance < ActionRadii.DETECTION:
		bacterium.set_nav_target(food_record.object.position)
		bacterium.intercept_target(food_record.object.position, food_record.object.velocity)
	
	if distance < ActionRadii.BITE:
		bacterium.bite_target(food_record.object)
