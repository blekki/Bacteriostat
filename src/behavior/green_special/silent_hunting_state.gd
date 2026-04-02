## Attension!!! : Works only with the "Green" bacteria
class_name SilentHuntingState
extends RefCounted

const DASH_POWER: int = 100
enum ActionRadii {	# in pixels
	VAMPIRISM = 50,
	ATTACK = 180,
	LURING = 230,
	HUNTING = 250,
}

var name: String = "Silent Hunting"

# <> Methods <>
static func do_task(bacterium: Bacterium):
	Debug.clean_layer(bacterium.debug_layer)
	_silent_hunting(bacterium)

static func try_update_behavior(bacterium: Bacterium):
	# photosintesizing section
	if Singlton.time_season == Enums.TimeSeasons.DAY:
		bacterium.change_state_to(StateMachine.photosynthesizing)
	
	# vampirist section
	var pray_record: InfoPack = InfoUtils.get_nearest_pray(bacterium.nearby_objects)
	if pray_record.object != null:
		var distance_to_pray = (bacterium.position - pray_record.object.position).length()
		if distance_to_pray < ActionRadii.VAMPIRISM:
			bacterium.chained_to = pray_record.object
			bacterium.change_state_to(StateMachine.vampirism)

# <> Algorithm requirements section <>
static func _silent_hunting(bacterium: Bacterium):
	# get the all nearby objects in the hunting area
	bacterium.nearby_objects = _get_nearby_objects(bacterium)
	
	# find a nearest prey
	if bacterium.nearby_objects.size() > 0:
		var pray_record: InfoPack = InfoUtils.get_nearest_pray(bacterium.nearby_objects)
		var is_nearby_lure: bool  = InfoUtils.is_lure_nearby(bacterium.nearby_objects)
		if pray_record.relationship != Enums.RelationshipTypes.NONE:
			_choice_action(bacterium, pray_record, is_nearby_lure)

static func _get_nearby_objects(observer: Bacterium) -> Array[InfoPack]:
	# init var's
	var unknown_objects = observer.get_nearby_objects(ActionRadii.HUNTING)	# can be EnergyCells or Bacteria
	var identified_objects: Array[InfoPack] = []
	
	# identification
	for object in unknown_objects:
		var relationship: Enums.RelationshipTypes = Enums.RelationshipTypes.NONE
		
		if object.has_method("get_bacterium_type"):
			relationship = _identify_relationship(object.get_bacterium_type())
		elif object.has_method("get_cell_type"):
			relationship = Enums.RelationshipTypes.INEDIBLE	# green bacteria can't eat energy cells
		
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

static func _identify_relationship(target: Enums.BacteriumTypes) -> Enums.RelationshipTypes:
	var relationship: Enums.RelationshipTypes
	
	if target == Enums.BacteriumTypes.GREEN:
		relationship = Enums.RelationshipTypes.NEUTRAL
	else: relationship = Enums.RelationshipTypes.PRAY		# anyway other bacteria is the prays
	
	return relationship

## Decide what kind action must be used if nearby environment full of objects.
static func _choice_action(bacterium: Bacterium, pray_info: InfoPack, is_nearby_lure: bool):
	var distance: float = (pray_info.object.position - bacterium.position).length()
	match distance:
		var a when (a < ActionRadii.ATTACK):
			bacterium.intercept_target(pray_info.object.position, pray_info.object.velocity)
		var a when (a < ActionRadii.LURING):
			if (is_nearby_lure != false) and (bacterium.is_ready_luring() == true):
				const lure_impulse: float = 100
				bacterium.throw_lure(lure_impulse)
