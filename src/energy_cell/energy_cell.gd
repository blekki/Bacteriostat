class_name EnergyCell
extends Entity

var cell_name: String = "Energy Cell"

# <> Methods section <>
func _ready():
	super()
	max_energy = 25
	energy = _random.randi_range(5, 12)
	rotation = _random.randf_range(-PI, PI)

func _physics_process(delta: float) -> void:
	super(delta)	# default physics

# <> other <>
func get_personal_name() -> String:
	return cell_name
