class_name FissionState
extends RefCounted

static var name: String = "Fission"

static func do_task(bacterium: Bacterium):
	bacterium.fission()

static func try_update_behavior(bacterium: Bacterium):
	if bacterium.is_ready_to_fission() == false:	# can't continue fissioning
		if (bacterium is GreenBacterium) or (bacterium is OrangeBacterium):
			bacterium.change_state_to(StateMachine.hunting_state)
		elif bacterium is PurpleBacterium:
			if WorldContext.is_day():
				bacterium.set_parameters_for_day()
				bacterium.change_state_to(StateMachine.cell_finding_state)
			else:
				bacterium.set_parameters_for_night()
				bacterium.change_state_to(StateMachine.hunting_state)
