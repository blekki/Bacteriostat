class_name VampirismState
extends RefCounted

static var name: String = "Vampirism"

# Parameter [bacterium] is needed to keep a duck typing abstaction
static func do_task(bacterium: Bacterium):
	Debug.clean_layer(bacterium.debug_layer)
	bacterium.vampirism(bacterium.chained_to)

static func try_update_behavior(bacterium: Bacterium):
	if bacterium.chained_to == null:
		bacterium.change_state_to(StateMachine.silent_hunting)
