# Data review logic for InfoPack
class_name InfoUtils
extends RefCounted

# <> section "the nearest object" <>
## Find nearest object with a special condition but if no one is, return empty [InfoPack]
static func _try_find_nearest_obj(array: Array[InfoPack], condition: Callable) -> InfoPack:
	const _RAW_INDEX: int = -1
	
	if array.size() == 0:
		return InfoPack.get_empty_pack()
	
	var nearest: float = INF
	var index: int = _RAW_INDEX
	for a in range(0, array.size()):
		if condition.call(array[a]):
			if array[a].object.position.length() < nearest:	# idk: i'm not sure is it correct
				index = a
	
	# return result
	if index == _RAW_INDEX:
		return InfoPack.get_empty_pack()
	else:
		return array[index]	# nearest prey

## Find nearest prey but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_prey(array: Array[InfoPack]) -> InfoPack:
	# prepare condition
	var condition = func(record: InfoPack):
		var is_prey = record.relationship == Enums.RelationshipTypes.PREY
		return is_prey
	
	return _try_find_nearest_obj(array, condition)

## Find nearest prey but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_energy_cell(array: Array[InfoPack]) -> InfoPack:
	# prepare condition
	var condition = func(record: InfoPack):
		var is_inedible = record.relationship == Enums.RelationshipTypes.INEDIBLE
		var is_edible = record.relationship == Enums.RelationshipTypes.EDIBLE
		var is_energy_cell = is_inedible or is_edible
		return is_energy_cell
	
	return _try_find_nearest_obj(array, condition)

## Find nearest predator but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_predator(array: Array[InfoPack]) -> InfoPack:
	# prepare condition
	var condition = func(record: InfoPack):
		var is_predator = record.relationship == Enums.RelationshipTypes.PREDATOR
		return is_predator
	
	return _try_find_nearest_obj(array, condition)

# <> section "is object nearby" <>
static func _try_find_obj(array: Array[InfoPack], condition: Callable) -> bool:
	var is_found: bool = false
	if array.size() == 0:
		return is_found
	
	for a in range(0, array.size()):
		if condition.call(array[a]):
			is_found = true
			break	# object is found, loop can be finished
	
	return is_found

static func is_lure_nearby(array: Array[InfoPack]) -> bool:
	# prepare condition
	var condition = func(record: InfoPack):
		var is_inedible = record.relationship == Enums.RelationshipTypes.INEDIBLE
		var is_edible = record.relationship == Enums.RelationshipTypes.EDIBLE
		var is_lure = is_inedible or is_edible
		return is_lure
	return _try_find_obj(array, condition)

static func is_predator_nearby(array: Array[InfoPack]) -> bool:
	# prepare condition
	var condition = func(record: InfoPack):
		var is_predator = record.relationship == Enums.RelationshipTypes.PREDATOR
		return is_predator
	return _try_find_obj(array, condition)
