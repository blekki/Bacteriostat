class_name WaitingState
extends RefCounted

static var name: String = "Waiting"

## Parameter [bacterium] is needed to keep a duck typing abstaction
static func apply(bacterium: Bacterium):
	# just wait... no more
	pass
