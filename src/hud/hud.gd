# HUD logic
class_name HUD
extends Control

# nodes
@onready var _info_panel: InfoPanel = $InfoPanel
var _time_season_label: Label = null
var _name_label: Label = null
var _texture_rect: TextureRect = null
var _info_label: Label = null

# parameters
var _tracked_object: Entity = null
var _is_hide_button_active: bool = false

# <> methods <>
func _ready():
	WorldContext.click_on_object_debug.connect(_on_click_on_object_debug)
	WorldContext.remove_object.connect(_on_remove_object)
	
	_time_season_label = $InfoPanel/PanelContainer/VBoxContainer/TimeSeasonPanel/SeasonInfo
	var _object_vbox: VBoxContainer = $InfoPanel/PanelContainer/VBoxContainer/ObjectPanel/VBox
	_name_label   = _object_vbox.get_node("ObjectName")
	_texture_rect = _object_vbox.get_node("ObjectTexture")
	_info_label   = _object_vbox.get_node("ObjectParameters")
	 
	_info_panel.hide()

func _process(_delta: float):
	_update_season_info()
	_update_object_info()

func _return_panel_on_screen():
	var camera = get_viewport().get_camera_2d()
	var viewport_size = camera.get_viewport_rect().size / camera.zoom
	var viewport_center = camera.get_screen_center_position()
	
	# find new panel position
	var target: Vector2 = viewport_center
	var offset_weight: float = 3.0
	if _info_panel.position.x < viewport_center.x:
		target -= (viewport_size / offset_weight)
	else:
		target.x += (viewport_size.x / offset_weight)
		target.y -= (viewport_size.y / offset_weight)
	
	_info_panel.replace_to(target)

# <> text changing <>
func _print_empty_page():
	_info_label.text  = "energy: 0 (DEAD)\n"

func _update_season_info():
	_time_season_label.text = WorldContext.get_season_info()

func _update_object_info():
	if _tracked_object == null:
		return
	
	_name_label.text = _tracked_object.get_personal_name()
	_texture_rect.texture = _tracked_object.get_texture()
	_info_label.text = _tracked_object.get_info()

# <> signals <>
## hide/show panel
func _on_hide_button_pressed():
	_is_hide_button_active = not _is_hide_button_active
	
	var container: VBoxContainer = $InfoPanel/PanelContainer/VBoxContainer
	var season_panel: PanelContainer = container.get_node("TimeSeasonPanel")
	var object_panel: PanelContainer = container.get_node("ObjectPanel")
	
	if _is_hide_button_active == true:
		season_panel.hide()
		object_panel.hide()
	else:
		season_panel.show()
		object_panel.show()

func _on_close_button_pressed():
	_info_panel.hide()

func _on_click_on_object_debug(object: CharacterBody2D):
	if object is InfoPanel:
		return
	 
	_tracked_object = object
	_update_object_info()
	_info_panel.show()
	
	# replace panel on screen if it's outside
	var panel_notifier = _info_panel.get_node("VisibleOnScreenNotifier2D")
	if not panel_notifier.is_on_screen():
		_return_panel_on_screen()

func _on_remove_object(object: Entity):
	if _tracked_object == object:
		_tracked_object = null
		_print_empty_page()
