class_name HUD
extends Control

# label pointers
var obj_name_label			# todo: rename
var obj_parameters_label	# todo: rename

# parameters
var checked_obj: Entity # can be bacterium or energy_cell

# <> methods <>
func _ready():
	Singlton.object_clicked.connect(_on_object_clicked)
	
	obj_name_label = $Panel/MarginContainer/VBox/ObjName
	obj_parameters_label = $Panel/MarginContainer/VBox/ObjParameters
	$Panel.hide()

func _process(delta: float):
	_update_info()

# <> text changing <>
func _update_info():
	if $Panel.visible == true:
		if checked_obj is Bacterium:
			_print_bacterium_info()
		elif checked_obj is EnergyCell:
			_print_energy_cell_info()

func _print_bacterium_info():
	obj_name_label.text = checked_obj.bacterium_name	# header
	# print parameters
	obj_parameters_label.text = ""
	obj_parameters_label.text += "energy: %d\n" % checked_obj.energy
	obj_parameters_label.text += "state: %s\n" % checked_obj.behavior_state.name
	obj_parameters_label.text += "priming: %.2f\n" % (checked_obj.action_priming / 60.0)	# idk: remove

func _print_energy_cell_info():
	obj_name_label.text = checked_obj.cell_name	# header
	# print parameters
	obj_parameters_label.text = "energy_equivalent: %d\n" % checked_obj.energy

# <> signals <>
func _on_close_button_pressed():
	$Panel.hide()

func _on_object_clicked(object: Entity):
	checked_obj = object
	_update_info()
	$Panel.show()
