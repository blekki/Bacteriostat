class_name StateMachine
extends RefCounted

static var waiting_state = WaitingState.new()
static var photosynthesis = PhotosynthesisState.new()
static var shadding = ShaddingState.new()
static var silent_hunting = SilentHuntingState.new()

static func get_start_green_bacterium_state() -> RefCounted:	# todo: set normal returning type
	return photosynthesis

static func get_start_purple_bacterium_state() -> RefCounted:	# todo: set normal returning type
	return waiting_state
