class_name StateMachine
extends RefCounted

static var waiting_state = WaitingState.new()
static var photosynthesizing_state = PhotosynthesizingState.new()
static var hunting_state = HuntingState.new()
static var cell_finding_state = CellFindingState.new()
static var vampirism_state = VampirismState.new()
static var fission_state = FissionState.new()
static var swim_away_state = SwimAwayState.new()

static func get_start_green_bacterium_state() -> RefCounted:	# todo: set normal returning type
	return photosynthesizing_state

static func get_start_orange_bacterium_state() -> RefCounted:	# todo: set normal returning type
	return hunting_state

static func get_start_purple_bacterium_state() -> RefCounted:	# todo: set normal returning type
	return cell_finding_state
