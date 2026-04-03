class_name WaitingState
extends RefCounted

static var name: String = "Waiting"

# Parameter [bacterium] is needed to keep a duck typing abstaction
static func do_task(bacterium: Bacterium):
	# just wait... no more
	pass

## need to keep solid abstraction
static func try_update_behavior(bacterium: Bacterium):
	pass
