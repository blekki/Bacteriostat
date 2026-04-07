# The simple struct for saving the variable pair
class_name InfoPack
extends RefCounted

var object: Entity = null
var relationship: Enums.RelationshipTypes = Enums.RelationshipTypes.NONE

func _init(object: Entity, relationship: Enums.RelationshipTypes):
	set_pack(object, relationship)

# can be used to a fast way save parameters
func set_pack(object: Entity, relationship: Enums.RelationshipTypes):
	self.object = object
	self.relationship = relationship

static func get_empty_pack() -> InfoPack:
	return InfoPack.new(null, Enums.RelationshipTypes.NONE)

# <> checking methods <>
func is_not_empty() -> bool:
	return (object != null)

func is_cell():
	return relationship == Enums.RelationshipTypes.CELL

func is_prey():
	return relationship == Enums.RelationshipTypes.PREY

func is_predator():
	return relationship == Enums.RelationshipTypes.PREDATOR
