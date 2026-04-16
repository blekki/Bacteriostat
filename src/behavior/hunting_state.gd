class_name HuntingState
extends RefCounted

var name: String = "Hunting"

# <> Methods <>
static func do_task(bacterium: Bacterium):
	bacterium.hunting()

static func try_update_behavior(bacterium: Bacterium):
	if bacterium is GreenBacterium:
		_green_bacterium_conditions(bacterium)
	elif bacterium is PurpleBacterium:
		_purple_bacterium_conditions(bacterium)
	elif bacterium is OrangeBacterium:
		_orange_bacterium_conditions(bacterium)

static func _green_bacterium_conditions(bacterium: GreenBacterium):
	if Singlton.is_day():
		bacterium.set_parameters_for_day()
		bacterium.change_state_to(StateMachine.photosynthesizing_state)
	
	# vampirist section
	var prey_record: InfoPack = InfoUtils.get_nearest_prey(bacterium.position, bacterium.nearby_objects)
	if prey_record.is_not_empty():
		var distance_to_prey = (prey_record.object.position - bacterium.position).length()
		if distance_to_prey < bacterium.attack_radius:
			bacterium.chained_to = prey_record.object
			bacterium.change_state_to(StateMachine.vampirism_state)

static func _purple_bacterium_conditions(bacterium: PurpleBacterium):
	if bacterium.is_ready_to_fission() == true:
		bacterium.change_state_to(StateMachine.fission_state)
	
	if Singlton.is_day():
		bacterium.set_parameters_for_day()
		bacterium.change_state_to(StateMachine.cell_finding_state)
	
	# should "swim" away
	var is_predator_nearby: bool = InfoUtils.is_predator_nearby(bacterium.nearby_objects)
	if is_predator_nearby == true:
		bacterium.change_state_to(StateMachine.swim_away_state)

static func _orange_bacterium_conditions(bacterium: OrangeBacterium):
	if bacterium.is_ready_to_fission() == true:
		bacterium.change_state_to(StateMachine.fission_state)
	
	if Singlton.is_night():
		bacterium.set_parameters_for_night()
		bacterium.change_state_to(StateMachine.hiding_state)
