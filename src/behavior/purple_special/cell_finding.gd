class_name CellFindingState
extends RefCounted

static var name: String = "Cell finding"

# <> method section <>
static func do_task(bacterium: PurpleBacterium):
	Debug.clean_layer(bacterium.debug_layer)
	bacterium.cell_finding()

static func try_update_behavior(bacterium: PurpleBacterium):
	if bacterium.is_ready_to_fission() == true:
		bacterium.change_state_to(StateMachine.fission_state)
	
	if Singlton.is_night():
		bacterium.change_state_to(StateMachine.hunting_state)
	
	# should "swim" away
	var is_predator_nearby: bool = InfoUtils.is_predator_nearby(bacterium.nearby_objects)
	if is_predator_nearby == true:
		bacterium.change_state_to(StateMachine.swim_away_state)
