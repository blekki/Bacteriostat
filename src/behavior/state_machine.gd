class_name StateMachine
extends RefCounted

static var photosynthesis = PhotosynthesisState.new()
static var energy_recycle = EnergyRecycleState.new()
static var shadding = ShaddingState.new()

static func get_start_green_bacterium_state() -> RefCounted:	# todo: set normal returning type
	return energy_recycle
