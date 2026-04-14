class_name Map
extends Node2D

const MAP_WIDTH = 1080		# in pixels
const MAP_HEIGHT = 720
const green_bacteria_instance  = preload("res://src/bacterium/green_bacterium.tscn")
const orange_bacteria_instance = preload("res://src/bacterium/orange_bacterium.tscn")
const purple_bacteria_instance = preload("res://src/bacterium/purple_bacterium.tscn")
const energy_cell_instance     = preload("res://src/energy_cell/energy_cell.tscn")

var bacteria: Array[Bacterium] = []
var energy_cells: Array[EnergyCell] = []

# <> technical
var _selected_object: CharacterBody2D = null

func _ready():
	Singlton.click_on_object.connect(_on_click_on_object)
	Singlton.energy_shed.connect(_on_energy_shed)
	Singlton.fission.connect(_on_fission)
	Singlton.remove_object.connect(_on_remove_object)
	
	await NavigationServer2D.map_changed
	_init_collision_walls()
	create_bacteria(100)
	create_energy_cell(100)
	_start_day()
	

func _physics_process(_delta: float):
	move_selected_object()

func _process(_delta: float):
	if Singlton.is_day():
		Singlton.season_continues = $Day.time_left
		Singlton.season_duration = $Day.wait_time
	else:
		Singlton.season_continues = $Night.time_left
		Singlton.season_duration = $Night.wait_time

# <> other methods <>
func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == false:
			# stop hold object
			if _selected_object != null:
				# shoot object in mouse direction after dragging
				const IMPULSE_MULTIPLIER: int = 10
				_selected_object.velocity = (get_local_mouse_position() - _selected_object.position) * IMPULSE_MULTIPLIER
			_selected_object = null

func _init_collision_walls():	# fast way make dynamic walls
	const UPSCALE = 1000
	const NO_SCALE = 1
	
	# move collision shapes and make them so long to looks like a walls
	var up_border = $Collision/UpSide
	up_border.position = Vector2(MAP_WIDTH / 2, 0)
	up_border.scale = Vector2(UPSCALE, NO_SCALE)
	
	var bottom_border = $Collision/BottomSide
	bottom_border.position = Vector2(MAP_WIDTH / 2, MAP_HEIGHT)
	bottom_border.scale = Vector2(UPSCALE, NO_SCALE)
	
	var left_border = $Collision/LeftSide
	left_border.position = Vector2(0, MAP_HEIGHT / 2)
	left_border.scale = Vector2(NO_SCALE, UPSCALE)
	
	var right_border = $Collision/RightSide
	right_border.position = Vector2(MAP_WIDTH, MAP_HEIGHT / 2)
	right_border.scale = Vector2(NO_SCALE, UPSCALE)

## save and add to scene object
func add_to_scene_bacterium(bacterium: Bacterium):
	var map_area = Vector2(MAP_WIDTH, MAP_HEIGHT)
	bacterium.setup(map_area)
	bacteria.push_back(bacterium)
	add_child(bacterium)

func add_to_scene_cell(cell: EnergyCell):
	var map_area = Vector2(MAP_WIDTH, MAP_HEIGHT)
	cell.setup(map_area)
	energy_cells.push_back(cell)
	add_child(cell)

func create_bacteria(count: int):
	for i in range(0, count):
		# set randomly bacterium type
		var num = randi_range(0, 2)
		var bacterium: Bacterium
		match num:
			0: bacterium = green_bacteria_instance.instantiate()
			1: bacterium = orange_bacteria_instance.instantiate()
			2: bacterium = purple_bacteria_instance.instantiate()
		
		add_to_scene_bacterium(bacterium)

func create_energy_cells(count: int):
	for i in range(0, count):
		var cell: EnergyCell = energy_cell_instance.instantiate()
		add_to_scene_cell(cell)

func move_selected_object():
	if _selected_object != null:
		const LERP_WEIGH: float = 0.2
		var new_position: Vector2 = lerp(_selected_object.position, get_local_mouse_position(), LERP_WEIGH)
		_selected_object.position = new_position

# <> signals section <>
func _on_click_on_object(object: Entity):
	object.velocity = Vector2.ZERO
	_selected_object = object

func _on_energy_shed(_position: Vector2, _impulse: Vector2, _energy: int):	# create energy_cell
	var map_area = Vector2(MAP_WIDTH, MAP_HEIGHT)
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
