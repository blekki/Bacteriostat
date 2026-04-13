# Class for objects physic declaration
class_name Entity
extends CharacterBody2D

# > pixel/physic_frame
const PASSIVE_DECELERATION: float = 2.0
const COLLISION_DEFLECTION: float = 5.0

@export var obj_name: String = "Raw Entity"
@export var energy: int = 50	# equivalent to health
@export var min_energy: int = 0
@export var max_energy: int = 100

# technical var's
var debug_layer: int = -1	# [-1] is as "nothing" code
var _navigation_field: Vector2 = Vector2.ZERO # area from (xy = 0) to (xy = nav_field.xy) pixels
var _random: RandomNumberGenerator = RandomNumberGenerator.new()

# <> Methods section <>
func setup(navigation_field: Vector2):
	_navigation_field = navigation_field

func _ready():
	_random.randomize()
	debug_layer = Debug.get_new_layer()
	position = _generate_smart_point()

func _physics_process(delta: float):
	_deceleration()
	_collision_fluence()
	move_and_slide()

func _generate_smart_point() -> Vector2:
	var point = Vector2(
		_random.randf_range(0, _navigation_field.x),
		_random.randf_range(0, _navigation_field.y)
	)
	return point

func _deceleration():
	if velocity.length() > PASSIVE_DECELERATION:
		velocity -= velocity.normalized() * PASSIVE_DECELERATION
	else:
		velocity = Vector2.ZERO

func _collision_fluence():
	var collision: KinematicCollision2D
	if get_slide_collision_count() > 0:
		collision = get_slide_collision(0)
	if collision:
		# todo: fix unsync fluence
		velocity += collision.get_normal() * (COLLISION_DEFLECTION)

func get_obj_name() -> String:
	return obj_name

## Need to safety object identification. Can be override to make complex identification.
func can_be_identified() -> bool:
	return true

# <> Health methods <>
## Change energy value
func consume_energy(delta_energy: int):
	var new_energy = clampi(energy + delta_energy, min_energy, max_energy)
	self.energy = new_energy
	if energy <= min_energy:
		death()

func spend_energy(delta_energy: int):
	consume_energy(-delta_energy)

## Return how much energy bacterium can consume
func can_consume_energy(delta_energy: int) -> int:
	var value = mini(delta_energy, max_energy - energy)
	return value

## Return how much energy bacterium can spend
func can_spend_energy(delta_energy: int) -> int:
	var value = mini(delta_energy, energy)
	return value

func death():
	Debug.clean_layer(debug_layer)	# todo: change to "remove_layer"
	modulate = Color.DIM_GRAY	# todo: change texture
	Singlton.remove_object.emit(self)

# <> reaction on signals section <>
func _on_clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		# signal that currect object was clicked
		if event.pressed:
			Singlton.click_on_object.emit(self)
