class_name Map
extends Node2D

const MAP_WIDTH = 1080		# in pixels
const MAP_HEIGHT = 720
const BACTERIAS_COUNT = 1
const green_bacteria_instance = preload("res://src/bacterium/green_bacterium.tscn")
const orange_bacteria_instance = preload("res://src/bacterium/orange_bacterium.tscn")
const purple_bacteria_instance = preload("res://src/bacterium/purple_bacterium.tscn")
const energy_cell_instance = preload("res://src/energy_cell/energy_cell.tscn")

var collision_borders: Array[CollisionShape2D] = []
var bacteria: Array[Bacterium] = []
var energy_cells: Array[EnergyCell] = []

var _selected_object: CharacterBody2D = null

func _ready():
	Singlton.click_on_object.connect(_on_click_ob_object)
	Singlton.energy_shed.connect(_on_energy_shed)
	Singlton.fission.connect(_on_fission)
	Singlton.remove_object.connect(_on_remove_object)
	
	await NavigationServer2D.map_changed
	_init_collision_walls()
	
	# generate bacterias
	for i in range(BACTERIAS_COUNT):
		var unit: Bacterium = bacteria_instance.instantiate()
		unit.set_navigation_field(Vector2(MAP_WIDTH, MAP_HEIGHT))	# need for correct positionate
		unit.energy_shed.connect(_on_bacterium_energy_shed)
		bacteria.push_back(unit)
		add_child(bacteria.back())
	
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

func move_selected_object():
	if _selected_object != null:
		const LERP_WEIGH: float = 0.2
		var new_position: Vector2 = lerp(_selected_object.position, get_local_mouse_position(), LERP_WEIGH)
		_selected_object.position = new_position

# <> signals section <>
func _on_click_ob_object(object: Entity):
	object.velocity = Vector2.ZERO
	_selected_object = object

func _on_energy_shed(position: Vector2, impulse: Vector2, energy: int):	# create energy_cell
	var cell: EnergyCell = energy_cell_instance.instantiate()
	cell.energy = energy
	cell.velocity = impulse
	
	# set start position
	const OFFSET: int = 30
	cell.position = position + impulse.normalized() * OFFSET	# tiny offset to solve collision problems
	
	# save energy_cell
	energy_cells.push_back(cell)
	add_child(cell)

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
