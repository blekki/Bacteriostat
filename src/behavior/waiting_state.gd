class_name WaitingState
extends RefCounted

static var name: String = "Waiting"

## Nothing do, just wait. Parameter [bacterium] is needed to keep a duck typing abstaction.
static func do_task(_bacterium: Bacterium):
	# just wait... no more
	pass

## Currect method doesn't update state. It is needed to keep solid abstraction.
## Parameter [bacterium] is needed to keep a duck typing abstaction.
static func try_update_behavior(_bacterium: Bacterium):
	# no change state
	pass
