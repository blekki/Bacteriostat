class_name SwimAwayState
extends RefCounted

static var name: String = "Swim away"

const ENEMY_DETECTION_RADIUS: float = 100	# todo: make universal detection area

static func do_task(bacterium: Bacterium):
	bacterium.swim_away(ENEMY_DETECTION_RADIUS)

static func try_update_behavior(bacterium: Bacterium):
	var is_predator_nearby = InfoUtils.is_predator_nearby(bacterium.nearby_objects)
	if is_predator_nearby == false:
		bacterium.change_state_to(StateMachine.grass_finding)
