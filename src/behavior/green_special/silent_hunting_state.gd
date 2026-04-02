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
	## get the all nearby objects in the hunting area
	#bacterium.nearby_objects = _get_nearby_objects(bacterium)
	
	# rules how to identified object
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if object.has_method("get_bacterium_type"):
			# comment: bacterium identification is complex, so logic was replaced
			return _bacterium_identification(object.get_bacterium_type())
		elif object.has_method("get_cell_type"):
			return Enums.RelationshipTypes.INEDIBLE	# green bacteria can't eat energy cells
		return Enums.RelationshipTypes.NONE # default
	
	# get the all nearby objects in the area
	bacterium.nearby_objects = bacterium.get_nearby_objects(ActionRadii.HUNTING, identification_rules)
	
	# find a nearest prey
	if bacterium.nearby_objects.size() > 0:
		var pray_record: InfoPack = InfoUtils.get_nearest_pray(bacterium.nearby_objects)
		var is_nearby_lure: bool  = InfoUtils.is_lure_nearby(bacterium.nearby_objects)
		if pray_record.relationship != Enums.RelationshipTypes.NONE:
			_choice_action(bacterium, pray_record, is_nearby_lure)

static func _bacterium_identification(target: Enums.BacteriumTypes) -> Enums.RelationshipTypes:
	if target == Enums.BacteriumTypes.GREEN:
		return Enums.RelationshipTypes.NEUTRAL
	else: return Enums.RelationshipTypes.PRAY		# anyway other bacteria is the prays

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
