# The simple struct for saving the variable pair
class_name InfoPack
extends RefCounted

var object: Variant
var object_type: Enums.ObjectTypes

func _init(object: Variant, object_type: Enums.ObjectTypes) -> void:
	set_pack(object, object_type)

# can be used to fast way save parameters
func set_pack(object: Variant, object_type: Enums.ObjectTypes):
	self.object = object
	self.object_type = object_type

static func get_empty_pack() -> InfoPack:
	return InfoPack.new(Vector2.ZERO, Enums.ObjectTypes.NONE)
