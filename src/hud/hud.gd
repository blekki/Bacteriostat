class_name HUD
extends Control

# label pointers
@onready var season_info: Label = $TimeSeasonPanel/MarginContainer/SeasonInfo
@onready var object_name: Label = $Panel/MarginContainer/VBox/ObjName
@onready var object_parameters: Label = $Panel/MarginContainer/VBox/ObjParameters

# parameters
var tracked_object: Entity = null

# <> methods <>
func _ready():
	Singlton.click_on_object.connect(_on_click_on_object)
	$Panel.hide()

func _process(delta: float):
	_update_season_info()
	_update_object_info()

# <> text changing <>
func _update_season_info():
	var current_season: String = "DAY" # default
	if Singlton.is_night():
		current_season = "NIGHT"
	
	# print info
	season_info.text  = "%.1f/" % Singlton.season_continues
	season_info.text += "%d " % Singlton.season_duration
	season_info.text += "(%s)" % current_season

func _update_object_info():
	if $Panel.visible == true:
		if tracked_object == null:
			_print_empty_page()
		elif tracked_object is Bacterium:
			_print_bacterium_info(tracked_object)
		elif tracked_object is EnergyCell:
			_print_energy_cell_info(tracked_object)

func _print_empty_page():
	object_name.text = "Object undefined"
	object_parameters.text  = "energy: ?\n"
	object_parameters.text += "state: ?\n"
	object_parameters.text += "priming: ?\n"
	object_parameters.text += "debug layer: ?\n"

## Parameter is needed to help text editor understand object
func _print_bacterium_info(object: Bacterium):
	# header
	object_name.text = tracked_object.bacterium_name
	# print parameters
	object_parameters.text  = ""
	object_parameters.text += "energy: %d/%d\n" % [object.energy, object.max_energy]
	object_parameters.text += "state: %s\n" % object.behavior_state.name
	object_parameters.text += "action: %s\n" % object.priming.get_action()
	object_parameters.text += "priming: %.1f\n" % object.priming.get_remaining_time()
	object_parameters.text += "debug layer: %d\n" % object.debug_layer

## Parameter is needed to help text redactor understand object
func _print_energy_cell_info(object: EnergyCell):
	object_name.text = object.cell_name
	object_parameters.text = "energy_equivalent: %d\n" % object.energy

# <> signals <>
func _on_close_button_pressed():
	$Panel.hide()

func _on_click_on_object(object: Entity):
	tracked_object = object
	_update_object_info()
	$Panel.show()
