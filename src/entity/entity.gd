# Class for objects physic declaration
class_name Entity
extends CharacterBody2D

const PASSIVE_DECELERATION: float = 2.0
const COLLISION_DEFLECTION: float = 5.0
const _MIN_ENERGY: int = 0	# default value	# todo: rename as "ENERGY_LIMIT" or same

var obj_name = "Raw Entity"
var energy: int = 0		# equivalent to health
var debug_layer: int = -1	# [-1] as "nothing" code
# technical var's
var _max_energy: int = 10	# default value
var _is_selected_with_mouse: bool = false	# todo: replace logic into world

# <> Methods section <>
func _init():
	debug_layer = Debug.get_new_layer()

func _physics_process(delta: float):
	if _is_selected_with_mouse == true:
		velocity = Vector2.ZERO
		global_position = lerp(global_position, get_global_mouse_position(), 10 * delta)
	
	_deceleration()
	_collision_fluence()
	move_and_slide()

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

# <> Health methods <>
## Change energy value
func consume_energy(delta_energy: int):
	var new_energy = clampi(energy + delta_energy, _MIN_ENERGY, _max_energy)
	self.energy = new_energy
	if energy <= _MIN_ENERGY:
		death()

func spend_energy(delta_energy: int):
	consume_energy(-delta_energy)

## Return how much energy bacterium can consume
func can_consume_energy(delta_energy: int) -> int:
	var value = mini(delta_energy, _max_energy - energy)
	return value

## Return how much energy bacterium can spend
func can_spend_energy(delta_energy: int) -> int:
	var value = mini(delta_energy, energy)
	return value

func death():
	Debug.clean_layer(debug_layer)	# todo: chnage to "remove_layer"
	modulate = Color.DIM_GRAY	# todo: change texture
	Singlton.remove_object.emit(self)

# <> reaction on signals section <>
func _on_clickable_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		# print info about the obj
		if event.pressed:
			Singlton.click_on_object.emit(self)
		
		# move the obj
		if Input.is_action_pressed("move_object"):
			_is_selected_with_mouse = true
		else: _is_selected_with_mouse = false
