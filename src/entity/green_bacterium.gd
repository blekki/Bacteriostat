class_name GreenBacterium
extends Bacterium

# <> method section <>
func _init():
	# override var's
	bacterium_name = "Green Bacterium"
	modulate = Color.LAWN_GREEN			# todo: change on texture
	behavior_state = StateMachine.get_start_green_bacterium_state();

func _ready():
	super()

func _physics_process(delta: float):
	super(delta)
