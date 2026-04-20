class_name SwimAwayState
extends RefCounted

static var name: String = "Swim away"

static func do_task(bacterium: Bacterium):
	bacterium.swim_away(bacterium.view_distance)

static func try_update_behavior(bacterium: Bacterium):
	var is_predator_nearby = InfoUtils.is_predator_nearby(bacterium.nearby_objects)
	if is_predator_nearby == false:
		# purple bacterium
		if bacterium is PurpleBacterium:
			if Singlton.is_day():
				bacterium.set_parameters_for_day()
				bacterium.change_state_to(StateMachine.cell_finding_state)
			else:
				bacterium.set_parameters_for_night()
				bacterium.change_state_to(StateMachine.hunting_state)
		# orange bacterium
		elif bacterium is OrangeBacterium:
			bacterium.change_state_to(StateMachine.hiding_state)
