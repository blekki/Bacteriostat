class_name HidingState
extends RefCounted

static var name: String = "Hiding"

static func do_task(bacterium: OrangeBacterium):
	bacterium.hiding()

static func try_update_behavior(bacterium: OrangeBacterium):
	if Singlton.is_day():
		bacterium.set_parameters_for_day()
		bacterium.stealth_mode_off()
		bacterium.change_state_to(StateMachine.hunting_state)
	
	if bacterium.should_swim_away():	# predator is to close
		bacterium.stealth_mode_off()
		bacterium.change_state_to(StateMachine.swim_away_state)
	
