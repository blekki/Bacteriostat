# The simple struct for saving the variable pair
class_name InfoPack
extends RefCounted

var object: Entity = null
var relationship: Enums.RelationshipTypes = Enums.RelationshipTypes.NONE

func _init(_object: Entity, _relationship: Enums.RelationshipTypes):
	set_pack(_object, _relationship)

# can be used to a fast way save parameters
func set_pack(_object: Entity, _relationship: Enums.RelationshipTypes):
	self.object = _object
	self.relationship = _relationship

static func get_empty_pack() -> InfoPack:
	return InfoPack.new(null, Enums.RelationshipTypes.NONE)

# <> checking methods <>
func is_not_empty() -> bool:
	return (object != null)

func is_lure():
	return relationship == Enums.RelationshipTypes.LURE

func is_prey():
	return relationship == Enums.RelationshipTypes.PREY

func is_predator():
	return relationship == Enums.RelationshipTypes.PREDATOR
