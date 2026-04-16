class_name World
extends Node2D

const MAP_WIDTH = 1920
const MAP_HEIGHT = 1080
const green_bacteria_instance  = preload("res://src/bacterium/green_bacterium.tscn")
const orange_bacteria_instance = preload("res://src/bacterium/orange_bacterium.tscn")
const purple_bacteria_instance = preload("res://src/bacterium/purple_bacterium.tscn")
const energy_cell_instance     = preload("res://src/energy_cell/energy_cell.tscn")

var bacteria: Array[Bacterium] = []
var energy_cells: Array[EnergyCell] = []

# <> technical
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
	create_bacteria(10)
	create_energy_cells(20)

func _physics_process(_delta: float):
	move_selected_object()

func _process(_delta: float):
	if Singlton.is_day():
		Singlton.season_continues = $Day.time_left
		Singlton.season_duration = $Day.wait_time
	else:
		Singlton.season_continues = $Night.time_left
		Singlton.season_duration = $Night.wait_time

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
	$Day.paused = not enable
	$Day.paused = not enable
	
	for b_unit in bacteria:
		b_unit.set_physics_updating(enable)
	for c_unit in energy_cells:
		c_unit.set_physics_updating(enable)

func move_selected_object():
	if _selected_object != null:
		const LERP_WEIGH: float = 0.2
		var new_position: Vector2 = lerp(_selected_object.position, get_local_mouse_position(), LERP_WEIGH)
		_selected_object.position = new_position

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
	const OFFSET: int = 30
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
	$Night.stop()
	Singlton.time_season = Enums.TimeSeasons.DAY
	$Day.start()

func _start_night():
	$Day.stop()
	Singlton.time_season = Enums.TimeSeasons.NIGHT
	$Night.start()

func _on_day_timeout():
	_start_night()

func _on_night_timeout():
	_start_day()
