class_name ShaddingState
extends RefCounted

func update(bacterium: Bacterium):
	# nothing
	pass
static var name: String = "Shadding"

func do_task(bacterium: Bacterium):
	bacterium.shedding()
	bacterium.behavior_state = StateMachine.photosynthesis
