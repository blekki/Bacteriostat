class_name EnergyCell
extends Entity

var cell_name: String = "Energy Cell"

# <> Methods section <>
func _init():
	_max_energy = 6000
	scale *= 0.4

func _physics_process(delta: float) -> void:
	super(delta)	# default physics
