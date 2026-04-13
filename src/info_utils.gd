# Data review logic for InfoPack
class_name InfoUtils
extends RefCounted

# <> section "the nearest object" <>
## Find nearest object with a special condition but if no one is, return empty [InfoPack]
static func _try_find_nearest_obj(parent_position: Vector2, array: Array[InfoPack], condition: Callable) -> InfoPack:
	if array.size() == 0:
		return InfoPack.get_empty_pack()
	
	const _RAW_INDEX: int = -1
	var object_index: int = _RAW_INDEX
	var shortest_distance: float = INF
	for a in range(0, array.size()):
		if condition.call(array[a]):	# pass object if it meets the conditions
			# find nearest object
			var object: Entity = array[a].object
			var distance = (object.position - parent_position).length()
			if distance < shortest_distance:
				shortest_distance = distance
				object_index = a
	
	# return result
	if object_index != _RAW_INDEX:
		return array[object_index]	# nearest prey
	else:
		return InfoPack.get_empty_pack()

## Find nearest prey but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_prey(parent_position: Vector2, array: Array[InfoPack]) -> InfoPack:
	# prepare condition
	var condition = func(record: InfoPack):
		return record.is_prey()
	
	return _try_find_nearest_obj(parent_position, array, condition)

## Find nearest prey but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_lure(parent_position: Vector2, array: Array[InfoPack]) -> InfoPack:
	# prepare condition
	var condition = func(record: InfoPack):
		return record.is_lure()
	
	return _try_find_nearest_obj(parent_position, array, condition)

## Find nearest predator but if no one is, return [Enums.ObjectTypes.NONE]
static func get_nearest_predator(parent_position: Vector2, array: Array[InfoPack]) -> InfoPack:
	# prepare condition
	var condition = func(record: InfoPack):
		return record.is_predator()
	
	return _try_find_nearest_obj(parent_position, array, condition)

# <> section "is object nearby" <>
static func _try_find_obj(array: Array[InfoPack], condition: Callable) -> bool:
	for a in range(0, array.size()):
		if condition.call(array[a]):
			return true	# found
	
	return false	# not found

static func is_lure_nearby(array: Array[InfoPack]) -> bool:
	# prepare condition
	var condition = func(record: InfoPack):
		var is_lure = record.is_lure()
		return is_lure
	
	return _try_find_obj(array, condition)

static func is_predator_nearby(array: Array[InfoPack]) -> bool:
	# prepare condition
	var condition = func(record: InfoPack):
		return record.is_predator()
	
	return _try_find_obj(array, condition)
