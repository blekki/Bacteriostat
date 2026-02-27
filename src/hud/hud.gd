class_name HUD
extends Control

# label pointers
var obj_name_label
var obj_parameters_label

# parameters
var last_checked_obj	# can be bacterium or energy_cell

# <> methods <>
func _ready():
	Singlton.bacterium_clicked.connect(_on_bacterium_clicked)
	Singlton.energy_cell_clicked.connect(_on_energy_cell_clicked)
	obj_name_label = $Panel/MarginContainer/VBox/ObjName
	obj_parameters_label = $Panel/MarginContainer/VBox/ObjParameters
	self.hide()

func _process(delta: float):
	_update_info()

# change text
func _update_info():
	if last_checked_obj is Bacterium:
		_print_bacterium_info()
	if last_checked_obj is EnergyCell:
		_print_energy_cell_info()

func _print_bacterium_info():
	# print header name
	obj_name_label.text = last_checked_obj.bacterium_name
	# print parameters
	obj_parameters_label.text = ""
	obj_parameters_label.text += "energy: %d\n" % last_checked_obj.energy
	obj_parameters_label.text += "state: %s\n" % last_checked_obj.behavior_state.name

func _print_energy_cell_info():
	# print header name
	obj_name_label.text = last_checked_obj.cell_name
	# print parameters
	obj_parameters_label.text = "energy_equivalent: %d\n" % last_checked_obj.energy_equivalent
	

# <> signals <>
func _on_close_button_pressed():
	self.hide()
	
func _on_bacterium_clicked(bacterium: Bacterium):
	last_checked_obj = bacterium
	_update_info()
	self.show()

func _on_energy_cell_clicked(energy_cell: EnergyCell):
	last_checked_obj = energy_cell
	_update_info()
	self.show()
