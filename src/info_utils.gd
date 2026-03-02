# Data review logic for InfoPack
class_name InfoUtils
extends RefCounted

## Find nearest pray but if no one is, return [Enums.ObjectTypes.NONE]
## Attention: Be careful this method works only if (array.size() > 0)
static func get_nearest_pray(array: Array[InfoPack]) -> InfoPack:
	var nearest: float = INF
	var index: int = -1
	
	# find nearest pray
	for i in range(0, array.size()):
		if array[i].object_type == Enums.ObjectTypes.PRAY:
			if array[i].object.position.length() < nearest:
				index = i
	
	# return result
	if index != -1:
		return array[index]	# nearest pray
	else:
		return InfoPack.new(Vector2.ZERO, Enums.ObjectTypes.NONE)	# literaly means "nothing"

static func get_nearest_energy_cell(array: Array[InfoPack]) -> InfoPack:
	var nearest: float = INF
	var index: int = -1
	
	# find nearest energy cell
	for i in range(0, array.size()):
		var is_inedible = array[i].object_type == Enums.ObjectTypes.INEDIBLE
		var is_edible = array[i].object_type == Enums.ObjectTypes.EDIBLE
		if is_inedible or is_edible:
			if array[i].object.position.length() < nearest:
				index = i
	
	# return result
	if index != -1:
		return array[index]	# nearest pray
	else:
		return InfoPack.new(Vector2.ZERO, Enums.ObjectTypes.NONE)	# literaly means "nothing"
