class_name Map
extends Node2D

const MAP_WIDTH = 1080		# in pixels
const MAP_HEIGHT = 720
const BACTERIAS_COUNT = 1
#const bacteria_instance = preload("res://src/bacterium/bacterium.tscn")
#const energy_cell_instance = preload("res://src/energy_cell/energy_cell.tscn")
const bacteria_instance = preload("res://src/entity/bacterium.tscn")
const energy_cell_instance = preload("res://src/entity/energy_cell.tscn")

var collision_borders: Array[CollisionShape2D] = []
var bacteria: Array[Bacterium] = []
var energy_cells: Array[EnergyCell] = []

func _ready():
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

func _on_energy_shed(position: Vector2, impulse: float, energy: int):	# create energy_cell
	var cell: EnergyCell = energy_cell_instance.instantiate()
	cell.cell_name = "Simple Cell"
	cell.type = Enums.EnergyCellTypes.GRASS
	cell.energy = energy
	cell.scale *= 0.4
	
	# add impulse to the cell
	var direction = Vector2.RIGHT.rotated(randf_range(0, PI * 2))
	var new_velocity = direction * impulse
	cell.velocity = new_velocity
	
	# set start position
	const OFFSET: int = 20
	cell.position = position + direction * OFFSET	# tiny offset for solve collision problems
	
	# save energy_cell
	energy_cells.push_back(cell)
	add_child(cell)

func _on_fission(parent: Bacterium):
	const FLAG_FULL_COPY: int = 7
	var child: Entity = parent.duplicate(FLAG_FULL_COPY)
	child.change_state_to(StateMachine.get_start_green_bacterium_state())
	
	# add bacterium child to scene
	bacteria.push_back(child)
	add_child(child)
	
	# Comment: Position sets after [add_child()] because then it gets default value
	
	# add impulse to a child
	const IMPULSE_POWER: int = 10
	var direction = Vector2.RIGHT.rotated(randf_range(0, PI * 2))
	var new_velocity = direction * IMPULSE_POWER
	child.velocity = new_velocity
	
	# add tiny offset to solve collision problems
	const OFFSET: int = 20
	child.position = parent.global_position + direction * OFFSET

func _on_remove_object(object: Entity):
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
	print("day started")

func _start_night():
	$Day.stop()
	Singlton.time_season = Enums.TimeSeasons.NIGHT
	$Night.start()
	print("night started")

func _on_day_timeout():
	_start_night()

func _on_night_timeout():
	_start_day()
