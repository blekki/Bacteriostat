# Data review logic for InfoPack
class_name InfoUtils
extends RefCounted

const _NEGATIVE_RESULT: bool = false
const _POSITIVE_RESULT: bool = true
const _RAW_INDEX: int = -1

# <> section "the nearest object" <>
## Find nearest object with a special condition but if no one is, return empty [InfoPack]
static func _try_find_nearest_obj(array: Array[InfoPack], condition: Callable) -> InfoPack:
	if array.size() == 0:
		return InfoPack.get_empty_pack()
	
	var nearest: float = INF
	var index: int = _RAW_INDEX
	for a in range(0, array.size()):
		if condition.call(array[a]):
			if array[a].object.position.length() < nearest:
				index = a
	
	# return result
	if index == _RAW_INDEX:
		return InfoPack.get_empty_pack()
	else:
		return array[index]	# nearest pray

## Find nearest pray but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_pray(array: Array[InfoPack]) -> InfoPack:
	# prepare condition
	var condition = func(record: InfoPack):
		var is_pray = record.relationship == Enums.RelationshipTypes.PRAY
		return is_pray
	
	return _try_find_nearest_obj(array, condition)

## Find nearest pray but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_energy_cell(array: Array[InfoPack]) -> InfoPack: # todo: separate "nearest_cell" into "nearest_grass" and "nearest_meat"
	# prepare condition
	var condition = func(record: InfoPack):
		var is_inedible = record.relationship == Enums.RelationshipTypes.INEDIBLE
		var is_edible = record.relationship == Enums.RelationshipTypes.EDIBLE
		var is_energy_cell = is_inedible or is_edible
		return is_energy_cell
	
	return _try_find_nearest_obj(array, condition)

# <> section "is object nearby" <>
static func _try_find_obj(array: Array[InfoPack], condition: Callable) -> bool:
	if array.size() == 0:
		return _NEGATIVE_RESULT
	
	var index: int = _RAW_INDEX
	for a in range(0, array.size()):
		if condition.call(array[a]):
			index = a
			break	# object is found, loop can be finished
	
	# return result
	if index == _RAW_INDEX:
		return _POSITIVE_RESULT
	else:
		return _NEGATIVE_RESULT

static func is_lure_nearby(array: Array[InfoPack]) -> bool:
	# prepare condition
	var condition = func(record: InfoPack):
		var is_inedible = record.relationship == Enums.RelationshipTypes.INEDIBLE
		var is_edible = record.relationship == Enums.RelationshipTypes.EDIBLE
		var is_lure = is_inedible or is_edible
		return is_lure
	return _try_find_obj(array, condition)
