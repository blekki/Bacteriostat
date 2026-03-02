## Attension!!! : Works only with the "Green" bacteria
class_name SilentHuntingState
extends RefCounted

const HUNTING_RADIUS: int = 250	# in pixels
const DASH_POWER: int = 100
# between "HUNTING_AREA" and "LURE_RADIUS" contains zone "NO_ACTION"
const LURE_RADIUS: int = 230
const DASH_RADIUS: int = 180
const VAMPIRISM_RADIUS: int = 50

var name: String = "Silent Hunting"

# <> methods <>
func apply(bacterium: Bacterium):
	_silent_hunting(bacterium)
	_try_change_state(bacterium)

func _silent_hunting(bacterium: Bacterium):
	# get the all nearby objects in the hunting area
	var nearby_objects: Array[InfoPack] = []
	nearby_objects = _environment_analyzer(bacterium)
	
	# find a nearest prey
	if nearby_objects.size() > 0:
		var pray_info: InfoPack = InfoUtils.get_nearest_pray(nearby_objects)
		if pray_info.object_type != Enums.ObjectTypes.NONE:
			_choice_action(bacterium, nearby_objects, pray_info)

func _environment_analyzer(observer: Bacterium) -> Array[InfoPack]:
	var unknown_objects = observer.nearby_objects(HUNTING_RADIUS)	# can be EnergyCells or Bacteria
	
	# init var's
	var nearby_objects: Array[InfoPack] = []
	var obj_type: Enums.ObjectTypes = Enums.ObjectTypes.NONE
	
	# identification
	for obj in unknown_objects:
		if obj.has_method("get_bacterium_type"):
			obj_type = _bacterium_analyzer(observer, obj.get_bacterium_type())
		if obj.has_method("get_cell_type"):
			obj_type = Enums.ObjectTypes.INEDIBLE	# green bacteria can't eat energy cells
		
		nearby_objects.push_back(
			InfoPack.new(obj, obj_type)
		)
		
		# remove in release version
		Debug.add_line(
			observer.debug_layer,
			observer.position,
			obj.get_pos(),
			Enums.DEBUG_OBJECT_COLORS[obj_type]
		)
	
	return nearby_objects

func _bacterium_analyzer(bacterium: Bacterium, target: Enums.BacteriumTypes) -> Enums.ObjectTypes:
	var relationship: Enums.ObjectTypes
	
	if target == Enums.BacteriumTypes.GREEN:
		relationship = Enums.ObjectTypes.NEUTRAL
	else: relationship = Enums.ObjectTypes.PRAY		# anyway other bacteria is the prays
	
	return relationship

## Decide what kind action must be used if nearby environment full of objects.
func _choice_action(bacterium: Bacterium, nearby_objects: Array[InfoPack], pray_info: InfoPack):
	var distance: float = (pray_info.object.position - bacterium.position).length()
	match distance:
		var a when (a < VAMPIRISM_RADIUS):
			bacterium.vampirism(pray_info.object)
		var a when (a < DASH_RADIUS):
			bacterium.smart_dash(DASH_POWER, pray_info.object)
		var a when (a < LURE_RADIUS):
			const lure_impulse: float = 100
			bacterium.try_throw_lure(lure_impulse, nearby_objects)

func _try_change_state(bacterium: Bacterium):
	# change the behavior to peaceful if a day has come
	if Singlton.time_season == Enums.TimeSeasons.DAY:
		Debug.remove_layer(bacterium.debug_layer)
		bacterium.behavior_state = StateMachine.photosynthesizing
