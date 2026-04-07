class_name VampirismState
extends RefCounted

static var name: String = "Vampirism"

static func do_task(bacterium: GreenBacterium):
	Debug.clean_layer(bacterium.debug_layer)
	bacterium.vampirism(bacterium.chained_to)

static func try_update_behavior(bacterium: GreenBacterium):
	if bacterium.is_ready_to_fission() == true:
		bacterium.change_state_to(StateMachine.fission_state)
	
	if bacterium.chained_to == null:	# lose connection
		bacterium.change_state_to(StateMachine.hunting_state)
