class_name PhotosynthesizingState
extends RefCounted

static var name: String = "Photosynthesizing"

# Parameter [bacterium] is needed to keep a duck typing abstaction
static func do_task(bacterium: Bacterium):
	Debug.clean_layer(bacterium.debug_layer)
	if bacterium.energy < bacterium.EnergyLimit.SHADING:
		bacterium.photosynthesizing()
	else:
		bacterium.shedding()

static func try_update_behavior(bacterium: Bacterium):
	## if night is comming
	if Singlton.time_season == Enums.TimeSeasons.NIGHT:
		bacterium.change_state_to(StateMachine.silent_hunting)	# new
