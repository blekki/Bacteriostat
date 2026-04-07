class_name FissionState
extends RefCounted

static var name: String = "Fission"

static func do_task(bacterium: Bacterium):
	Debug.clean_layer(bacterium.debug_layer)
	bacterium.fission()

static func try_update_behavior(bacterium: Bacterium):
	if bacterium.is_ready_to_fission() == false:	# can't continue fissioning
		if bacterium is GreenBacterium:
			bacterium.change_state_to(StateMachine.hunting_state)
		elif bacterium is PurpleBacterium:
			if Singlton.is_day():
				bacterium.change_state_to(StateMachine.cell_finding_state)
			else:
				bacterium.change_state_to(StateMachine.hunting_state)
		elif bacterium is OrangeBacterium:
			pass # todo: add state changing
