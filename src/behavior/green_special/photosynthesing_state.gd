class_name PhotosynthesizingState
extends RefCounted

static var name: String = "Photosynthesizing"

static func do_task(bacterium: GreenBacterium):
	Debug.clean_layer(bacterium.debug_layer)
	if bacterium.is_ready_to_shedding() == false:
		bacterium.photosynthesizing()
	else:
		bacterium.shedding()

static func try_update_behavior(bacterium: GreenBacterium):
	if Singlton.is_night():
		bacterium.set_parameters_for_night()
		bacterium.change_state_to(StateMachine.hunting_state)
