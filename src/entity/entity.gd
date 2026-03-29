# Class for objects physic declaration
class_name Entity
extends CharacterBody2D

const PASSIVE_DECELERATION: float = 2.0
const COLLISION_DEFLECTION: float = 5.0

var obj_name = "Raw Entity"
var energy: int = 0		# equivalent to health
var debug_layer: int = -1	# [-1] as "nothing" code
var _is_selected_with_mouse: bool = false	# todo: replace logic into world

# <> Methods section <>
func _ready():
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
	var collision
	if get_slide_collision_count() > 0:
		collision = get_slide_collision(0)
	if collision:
		var collider = collision.get_collider()		# todo: fix unsync fluence
		velocity += collision.get_normal() * (COLLISION_DEFLECTION)

func get_obj_name() -> String:
	return obj_name
	
func death():
	#Debug.remove_layer(debug_layer)
	Debug.clean_layer(debug_layer)	# todo: chnage to "remove_layer"
	modulate = Color.DIM_GRAY	# todo: change texture
	# todo: add signal to map remove obj

# <> other <>
func _on_clickable_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		# print info about the obj
		if event.pressed:
			Singlton.click_on_object.emit(self)
		
		# move the obj
		if Input.is_action_pressed("move_object"):
			_is_selected_with_mouse = true
		else: _is_selected_with_mouse = false
