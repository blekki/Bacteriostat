class_name ShaddingState
extends RefCounted

func update(bacterium: Bacterium):
	# nothing
	pass

func do_task(bacterium: Bacterium):
	bacterium.shedding()
	bacterium.behavior_state = StateMachine.photosynthesis
