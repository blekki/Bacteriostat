class_name Map
extends Node2D

const MAP_WIDTH = 1080		# in pixels
const MAP_HEIGHT = 720
const BACTERIAS_COUNT = 1
const bacteria_instance = preload("res://src/bacterium/bacterium.tscn")
const energy_cell_instance = preload("res://src/energy_cell/energy_cell.tscn")

var collision_borders: Array[CollisionShape2D] = []
var bacteria: Array[Bacterium] = []
var energy_cells: Array[EnergyCell] = []

func _ready():
	_init_collision_walls()
	
	# generate bacterias
	for i in range(BACTERIAS_COUNT):
		var unit: Bacterium = bacteria_instance.instantiate()
		unit.set_navigation_field(Vector2(MAP_WIDTH, MAP_HEIGHT))	# need for correct positionate
		unit.energy_shed.connect(_on_bacterium_energy_shed)
		bacteria.push_back(unit)
		add_child(bacteria.back())
		
	_start_day()

func _process(delta: float):
	pass

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

func _on_bacterium_energy_shed(global_position: Vector2, energy: int):	# create energy_cell
	var cell: EnergyCell = energy_cell_instance.instantiate()
	cell.energy_equivalent = energy
	
	# create random impuls in random direction
	const MIN_IMPULSE: int = 40
	const MAX_IMPULSE: int = 80
	var power = randf_range(MIN_IMPULSE, MAX_IMPULSE)
	var direction = Vector2.RIGHT.rotated(randf_range(0, PI * 2))
	var impulse = direction * power
	cell.velocity = impulse
	
	# set start position
	const OFFSET: int = 20
	cell.global_position = global_position + direction * OFFSET	# tiny offset for solve collision problems
	
	# save energy_cell
	energy_cells.push_back(cell)
	add_child(energy_cells.back())

# time season configuration
func _start_day():
	$Night.stop()
	print("night finished")
	Singlton.time_season = Enums.TimeSeasons.DAY
	$Day.start()

func _start_night():
	$Day.stop()
	print("day finished")
	Singlton.time_season = Enums.TimeSeasons.NIGHT
	$Night.start()

func _on_day_timeout():
	_start_night()

func _on_night_timeout():
	_start_day()
