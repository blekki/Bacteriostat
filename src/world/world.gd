class_name World
extends Node2D

const MAP_WIDTH = 1920
const MAP_HEIGHT = 1080
const green_bacteria_instance  = preload("res://src/bacterium/green_bacterium.tscn")
const orange_bacteria_instance = preload("res://src/bacterium/orange_bacterium.tscn")
const purple_bacteria_instance = preload("res://src/bacterium/purple_bacterium.tscn")
const energy_cell_instance     = preload("res://src/energy_cell/energy_cell.tscn")

@export var day_shader_color: Color = Color(1.0, 1.0, 1.0, 1.0);
@export var night_shader_color: Color = Color(0.597, 0.702, 0.918, 1.0);
var bacteria: Array[Bacterium] = []
var energy_cells: Array[EnergyCell] = []

# <> technical
@onready var _season_shader: CanvasModulate = $SeasonShader
@onready var _day_timer: Timer = $DayTimer
@onready var _night_timer: Timer = $NightTimer
var _season_animation: Tween = create_tween()
var _is_simulation_run: bool = true
var _selected_object: CharacterBody2D = null

func _ready():
	Singlton.click_on_object.connect(_on_click_on_object)
	Singlton.energy_shed.connect(_on_energy_shed)
	Singlton.fission.connect(_on_fission)
	Singlton.remove_object.connect(_on_remove_object)
	
	_setup_navigation_field()
	_setup_collision_walls()
	_start_day()
	create_bacteria(80)
	create_energy_cells(40)

func _physics_process(_delta: float):
	move_selected_object()

func _process(_delta: float):
	rescale_shaders_rect()
	if Singlton.is_day():
		Singlton.season_continues = _day_timer.time_left
		Singlton.season_duration = _day_timer.wait_time
	else:
		Singlton.season_continues = _night_timer.time_left
		Singlton.season_duration = _night_timer.wait_time

func rescale_shaders_rect():
	var cam = get_viewport().get_camera_2d()
	var center = cam.get_screen_center_position()
	var viewport_size = get_viewport_rect().size / cam.zoom
	
	## Stretch shaders on the all window
	var water = $Background/BackgroundShader
	var blur  = $Background/BlurShader
	var wales = $Wales/WalesShader
	water.position = center
	blur.position  = center
	wales.position = center
	water.scale = viewport_size
	blur.scale  = viewport_size
	wales.scale = viewport_size

func _setup_navigation_field():
	var half_width: float = MAP_WIDTH / 2.0
	var half_height: float = MAP_HEIGHT / 2.0
	var points = PackedVector2Array([
		Vector2(-half_width, -half_height),
		Vector2( half_width, -half_height),
		Vector2( half_width,  half_height),
		Vector2(-half_width,  half_height)
	])
	
	var new_polygon: NavigationPolygon = NavigationPolygon.new()
	new_polygon.add_outline(points)
	new_polygon.make_polygons_from_outlines()
	
	var nav_region: NavigationRegion2D = $NavigationRegion2D
	nav_region.navigation_polygon = new_polygon
	nav_region.bake_navigation_polygon()
	await NavigationServer2D.map_changed

func _setup_collision_walls():
	# cillision walls
	var half_width: float = MAP_WIDTH / 2.0
	var half_height: float = MAP_HEIGHT / 2.0
	
	var up_side = $Collision/UpSide
	up_side.position.y = -half_height
	up_side.scale.x *= half_width
	
	var bottom_side = $Collision/BottomSide
	bottom_side.position.y = half_height
	bottom_side.scale.x *= half_width
	
	var left_side = $Collision/LeftSide
	left_side.position.x = -half_width
	left_side.scale.y *= half_height
	
	var right_side = $Collision/RightSide
	right_side.position.x = half_width
	right_side.scale.y *= half_height
	
	# border line
	var new_points = PackedVector2Array([
		Vector2(-half_width, -half_height),
		Vector2( half_width, -half_height),
		Vector2( half_width,  half_height),
		Vector2(-half_width,  half_height),
		Vector2(-half_width, -half_height)
	])
	var line = $BorderLine
	line.points = new_points

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			# stop hold object
			if _selected_object != null:
				# shoot object in mouse direction after dragging
				const IMPULSE_MULTIPLIER: int = 10
				_selected_object.velocity = (get_local_mouse_position() - _selected_object.position) * IMPULSE_MULTIPLIER
			_selected_object = null
	
	if event.is_action_pressed("simulation_control"):
		set_simulation(not _is_simulation_run)

func set_simulation(enable: bool):
	_is_simulation_run = enable
	_day_timer.paused = not enable
	_night_timer.paused = not enable
	
	if enable and _season_animation.is_valid():
		_season_animation.play()
	else: _season_animation.pause()
	
	for b_unit in bacteria:
		b_unit.set_physics_updating(enable)
	for c_unit in energy_cells:
		c_unit.set_physics_updating(enable)

func move_selected_object():
	if _selected_object != null:
		const LERP_WEIGH: float = 0.2
		var new_position: Vector2 = lerp(_selected_object.position, get_local_mouse_position(), LERP_WEIGH)
		_selected_object.position = new_position

func update_season_filter(target_color: Color):
	if _season_animation:	# does already work
		_season_animation.kill()
	
	# create new animation
	const DURATION: float = 2.0
	_season_animation = create_tween()
	_season_animation.tween_property(_season_shader, "color", target_color, DURATION)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

# <> create object section <>
func add_to_scene_bacterium(bacterium: Bacterium):
	bacterium.setup_nav_field(
		Vector2(MAP_WIDTH / -2.0, MAP_HEIGHT / -2.0),
		Vector2(MAP_WIDTH /  2.0, MAP_HEIGHT /  2.0)
	)
	bacteria.push_back(bacterium)
	add_child(bacterium)

func add_to_scene_cell(cell: EnergyCell):
	cell.setup_nav_field(
		Vector2(MAP_WIDTH / -2.0, MAP_HEIGHT / -2.0),
		Vector2(MAP_WIDTH /  2.0, MAP_HEIGHT /  2.0)
	)
	energy_cells.push_back(cell)
	add_child(cell)

func create_bacteria(count: int):
	for i in range(0, count):
		var bacterium: Bacterium
		match randi_range(0, 2):	# set randomly bacterium type
			0: bacterium = green_bacteria_instance.instantiate()
			1: bacterium = orange_bacteria_instance.instantiate()
			2: bacterium = purple_bacteria_instance.instantiate()
		add_to_scene_bacterium(bacterium)

func create_energy_cells(count: int):
	for i in range(0, count):
		var cell: EnergyCell = energy_cell_instance.instantiate()
		add_to_scene_cell(cell)

# <> signals section <>
func _on_click_on_object(object: CharacterBody2D):
	object.velocity = Vector2.ZERO
	_selected_object = object

func _on_energy_shed(_position: Vector2, _impulse: Vector2, _energy: int):	# create energy_cell
	var cell: EnergyCell = energy_cell_instance.instantiate()
	add_to_scene_cell(cell)
	
	# change cell parameters
	cell.energy = _energy
	cell.velocity = _impulse
	
	const OFFSET: float = 30.0
	cell.position = _position + _impulse.normalized() * OFFSET	# tiny offset to solve collision problems

func _on_fission(parent: Bacterium):
	# prepare child object
	var child = parent.duplicate(DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS | DUPLICATE_INTERNAL_STATE | DUPLICATE_USE_INSTANTIATION)
	bacteria.push_back(child)
	add_child(child)
	
	# Comment: a couple parameters set after [add_child()] because then it gets default value
	# add impulse to a child
	const IMPULSE_POWER: int = 10
	var direction = Vector2.RIGHT.rotated(randf_range(0, PI * 2))
	var new_velocity = direction * IMPULSE_POWER
	child.velocity = new_velocity
	
	# add tiny offset to solve collision problems
	const OFFSET: int = 55
	child.position = parent.global_position + direction * OFFSET

func _on_remove_object(object: Entity):
	if object == _selected_object:
		_selected_object = null
	
	if object is Bacterium:
		bacteria.erase(object)
	elif object is EnergyCell:
		energy_cells.erase(object)
	
	object.queue_free()	# literally remove object

# time season configuration
func _start_day():
	_night_timer.stop()
	Singlton.time_season = Enums.TimeSeasons.DAY
	update_season_filter(day_shader_color)
	_day_timer.start()

func _start_night():
	_day_timer.stop()
	Singlton.time_season = Enums.TimeSeasons.NIGHT
	update_season_filter(night_shader_color)
	_night_timer.start()

func _on_day_timeout():
	_start_night()

func _on_night_timeout():
	_start_day()
