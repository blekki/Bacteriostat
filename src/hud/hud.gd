class_name HUD
extends Control

# label pointers
@onready var object_name: Label = $Panel/MarginContainer/VBox/ObjName
@onready var object_parameters: Label = $Panel/MarginContainer/VBox/ObjParameters

# parameters
var tracked_object: Entity = null

# <> methods <>
func _ready():
	Singlton.click_on_object.connect(_on_click_on_object)
	$Panel.hide()

func _process(delta: float):
	_update_info()

# <> text changing <>
func _update_info():
	if $Panel.visible == true:
		if tracked_object == null:
			_print_empty_page()
		elif tracked_object is Bacterium:
			_print_bacterium_info()
		elif tracked_object is EnergyCell:
			_print_energy_cell_info()

func _print_empty_page():
	object_name.text = "Object undefined"
	object_parameters.text  = "energy: ?\n"
	object_parameters.text += "state: ?\n"
	object_parameters.text += "priming: ?\n"
	object_parameters.text += "debug layer: ?\n"

func _print_bacterium_info():
	object_name.text = tracked_object.bacterium_name	# header
	# print parameters
	object_parameters.text  = ""
	object_parameters.text += "energy: %d\n" % tracked_object.energy
	object_parameters.text += "state: %s\n" % tracked_object.behavior_state.name
	object_parameters.text += "priming: %.2f\n" % (tracked_object.action_priming / 60.0)
	object_parameters.text += "debug layer: %d\n" % tracked_object.debug_layer

func _print_energy_cell_info():
	object_name.text = tracked_object.cell_name	# header
	object_parameters.text = "energy_equivalent: %d\n" % tracked_object.energy	# print parameters

# <> signals <>
func _on_close_button_pressed():
	$Panel.hide()

func _on_click_on_object(object: Entity):
	tracked_object = object
	_update_info()
	$Panel.show()
