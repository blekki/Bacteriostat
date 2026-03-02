class_name ShaddingState
extends RefCounted

static var name: String = "Shadding"

static func apply(bacterium: Bacterium):
	_shedding(bacterium)
	_change_state(bacterium)

static func _shedding(bacterium: Bacterium):
	const MIN_IMPULSE: int = 80
	const MAX_IMPULSE: int = 120
	var impulse = randf_range(MIN_IMPULSE, MAX_IMPULSE)
	bacterium.shedding(impulse)

static func _change_state(bacterium: Bacterium):
	bacterium.behavior_state = StateMachine.photosynthesis
