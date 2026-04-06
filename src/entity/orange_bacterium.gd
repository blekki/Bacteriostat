class_name OrangeBacterium
extends Bacterium

# <> method section <>
func _ready():
	super()	# set default parameters
	
	# override var's
	bacterium_name = "Orange Bacterium"
	modulate = Color.ORANGE				# todo: change on texture
	behavior_state = StateMachine.get_start_orange_bacterium_state();
	
	# todo: set personal action radii

func _physics_process(delta: float):
	super(delta)
