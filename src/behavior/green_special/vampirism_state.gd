class_name VampirismState
extends RefCounted

static var name: String = "Vampirism"

static func do_task(bacterium: GreenBacterium):
	var prey: Entity = bacterium.chained_to
	if is_instance_valid(prey):
		bacterium.vampirism(prey)

static func try_update_behavior(bacterium: GreenBacterium):
	if bacterium.is_ready_to_fission() == true:
		bacterium.change_state_to(StateMachine.fission_state)
	
	if bacterium.chained_to == null:	# lose connection
		bacterium.change_state_to(StateMachine.hunting_state)
