class_name PurpleBacterium
extends Bacterium

# <> method section <>
func _init():
	# override var's
	bacterium_name = "Purple Bacterium"
	modulate = Color.PURPLE				# todo: change on texture
	behavior_state = StateMachine.get_start_purple_bacterium_state();

func _ready():
	super()

func _physics_process(delta: float):
	super(delta)
