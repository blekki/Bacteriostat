class_name Map
extends Node2D

const MAP_WIDTH = 1080		# in pixels
const MAP_HEIGHT = 720

const bacteria_instance = preload("res://src/bacteria/bacteria.tscn")
const BACTERIAS_COUNT = 1

var collision_borders: Array[CollisionShape2D] = []
var bacterias: Array[Bacteria] = []

func _ready() -> void:
	_init_collision_walls()
	
	# generate bacterias
	for i in range(BACTERIAS_COUNT):
		var unit: Bacteria = bacteria_instance.instantiate()
		unit.set_navigation_field(Vector2(MAP_WIDTH, MAP_HEIGHT))	# need for correct positionate
		bacterias.push_back(unit)
		add_child(bacterias.back())

func _process(delta: float) -> void:
	pass

func _init_collision_walls():
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
