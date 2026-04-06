class_name SwimAwayState
extends RefCounted

static var name: String = "Swim away"

static func do_task(bacterium: Bacterium):
	Debug.clean_layer(bacterium.debug_layer)
	bacterium.swim_away(bacterium.view_distance)

static func try_update_behavior(bacterium: Bacterium):
	var is_predator_nearby = InfoUtils.is_predator_nearby(bacterium.nearby_objects)
	if is_predator_nearby == false:
		if bacterium is PurpleBacterium:
			if Singlton.is_day():
				bacterium.change_state_to(StateMachine.cell_finding_state)
			else:
				bacterium.change_state_to(StateMachine.hunting_state)
		elif bacterium is OrangeBacterium:
			pass	# todo: add instruction
