class_name FissionState
extends RefCounted

static var name: String = "Fission"

# Parameter [bacterium] is needed to keep a duck typing abstaction
static func do_task(bacterium: Bacterium):
	Debug.clean_layer(bacterium.debug_layer)
	bacterium.fission()

static func try_update_behavior(bacterium: Bacterium):
	if bacterium.energy < bacterium.EnergyLimit.FISSION:
		if bacterium.type == Enums.BacteriumTypes.GREEN:
			bacterium.change_state_to(StateMachine.silent_hunting)
		# todo: extend list
