# The simple struct for saving the variable pair
class_name InfoPack	# todo: rename InfoPack
extends RefCounted

var object: Variant
#var position: Vector2		# OLD
var object_type: Enums.ObjectTypes

func _init(object: Variant, object_type: Enums.ObjectTypes) -> void:
	set_pack(object, object_type)

# can be used to fast way save parameters
func set_pack(object: Variant, object_type: Enums.ObjectTypes):
	self.object = object
	self.object_type = object_type
