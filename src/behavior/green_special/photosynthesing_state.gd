class_name PhotosynthesizingState
extends RefCounted

static var name: String = "Photosynthesizing"

static func apply(bacterium: Bacterium):
	_photosynthesing(bacterium)
	_try_change_state(bacterium)

static func _photosynthesing(bacterium: Bacterium):
	bacterium.photosynthesing()

static func _try_change_state(bacterium: Bacterium):
	# if night is comming
	if Singlton.time_season == Enums.TimeSeasons.NIGHT:
		bacterium.behavior_state = StateMachine.silent_hunting
	# if too much energy
	if bacterium.energy >= bacterium.OVERAGE_ENERGY_LIMIT:
		bacterium.behavior_state = StateMachine.shadding
