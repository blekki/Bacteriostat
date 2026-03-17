# Data review logic for InfoPack
class_name InfoUtils
extends RefCounted

const RESULT_NONE: int = -1

## Find nearest pray but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_pray(array: Array[InfoPack]) -> InfoPack:
	if array.size() == 0:
		return InfoPack.get_empty_pack()

	var nearest: float = INF
	var index: int = RESULT_NONE
	
	# find nearest pray
	for i in range(0, array.size()):
		if array[i].object_type == Enums.ObjectTypes.PRAY:
			if array[i].object.position.length() < nearest:
				index = i
	
	# return result
	if index == RESULT_NONE:
		return InfoPack.get_empty_pack()	# literaly means "nothing"
	else:
		return array[index]	# nearest pray

## Find nearest pray but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_energy_cell(array: Array[InfoPack]) -> InfoPack: # todo: separate "nearest_cell" into "nearest_grass" and "nearest_meat"
	if array.size() == 0:
		return InfoPack.get_empty_pack()
	
	var nearest: float = INF
	var index: int = RESULT_NONE
	
	# find nearest energy cell
	for i in range(0, array.size()):
		var is_inedible = array[i].object_type == Enums.ObjectTypes.INEDIBLE
		var is_edible = array[i].object_type == Enums.ObjectTypes.EDIBLE
		if is_inedible or is_edible:
			if array[i].object.position.length() < nearest:
				index = i
	
	# return result
	if index == RESULT_NONE:
		return InfoPack.get_empty_pack()
	else:
		return array[index]	# nearest pray
