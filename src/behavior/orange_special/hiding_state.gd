class_name HidingState
extends RefCounted

static var name: String = "Hiding"

static func do_task(bacterium: OrangeBacterium):
	Debug.clean_layer(bacterium.debug_layer)
	bacterium.hiding()

static func try_update_behavior(bacterium: OrangeBacterium):
	if Singlton.is_day():
		bacterium.stealth_mode_off()
		bacterium.change_state_to(StateMachine.hunting_state)
