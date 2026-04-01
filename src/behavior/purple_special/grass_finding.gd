class_name GrassFindingState	# todo: rename to CellFinding
extends RefCounted

static var name: String = "GrassFinding"

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

static func _grass_finding(bacterium: Bacterium):
	# get the all nearby objects in the area
	var nearby_objects: Array[InfoPack] = []
	nearby_objects = _get_nearby_objects(bacterium)
	
	# find a nearest food
	if nearby_objects.size() > 0:
		var food_record: InfoPack = InfoUtils.get_nearest_energy_cell(nearby_objects)
		if food_record.relationship != Enums.RelationshipTypes.NONE:
			_choice_action(bacterium, food_record)
			return	# skip changing place
	
	change_place(bacterium)

static func change_place(bacterium: Bacterium):
	# continue find
	if bacterium.is_target_reached():
		bacterium.generate_new_nav_target()
	else:
		var target = bacterium.get_nav_target() 
		bacterium.reach_target(target)

static func _get_nearby_objects(observer: Bacterium) -> Array[InfoPack]:
	# init var's
	var unknown_objects = observer.get_nearby_objects(ActionRadii.DETECTION)	# can be EnergyCells or Bacteria
	var identified_objects: Array[InfoPack] = []
	
	# identification
	for object in unknown_objects:
		var relationship: Enums.RelationshipTypes = Enums.RelationshipTypes.NONE
		
		if object.has_method("get_cell_type"):
			relationship = Enums.RelationshipTypes.EDIBLE
		
		identified_objects.push_back(
			InfoPack.new(object, relationship)
		)
		
		# DEBUG:
		Debug.add_line(
			observer.debug_layer,
			observer.position,
			object.position,
			Enums.DEBUG_RELATIONSHIP_COLORS[relationship]
		)
	
	return identified_objects

static func _choice_action(bacterium: Bacterium, food_record: InfoPack):
	var distance: float = (food_record.object.position - bacterium.position).length()
	
	if distance < ActionRadii.DETECTION:
		bacterium.set_nav_target(food_record.object.position)
		bacterium.intercept_target(food_record.object.position, food_record.object.velocity)
	
	if distance < ActionRadii.BITE:
		bacterium.bite_target(food_record.object)
