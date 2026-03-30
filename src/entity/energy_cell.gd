class_name EnergyCell
extends Entity

var cell_name: String = "Unknown Cell"
var type: Enums.EnergyCellTypes

# <> Methods section <>
func _init():
	_max_energy = 60

func _physics_process(delta: float) -> void:
	super(delta)	# default physics

# <> other methods <>
func get_obj_name() -> String:
	return cell_name

# <> need for identification "get" methods <>
func get_cell_type() -> Enums.EnergyCellTypes:
	return type
