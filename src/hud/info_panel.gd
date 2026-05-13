# Logic of panel (physics)
class_name InfoPanel
extends CharacterBody2D

# > pixel/physic_frame
const PASSIVE_DECELERATION: float = 30.0

var expected_position: Vector2 = position
var _is_auto_replace_on: bool = false

# <> methods section <>
func _physics_process(_delta: float) -> void:
	_deceleration()
	auto_replace()
	move_and_slide()

func _deceleration():
	if velocity.length() > PASSIVE_DECELERATION:
		velocity -= velocity.normalized() * PASSIVE_DECELERATION
	else:
		velocity = Vector2.ZERO

func auto_replace():
	if position == expected_position:	# already on position
		_is_auto_replace_on = false
		return
	
	if _is_auto_replace_on:
		const WEIGHT: float = 0.2
		position = lerp(position, expected_position, WEIGHT)

func replace_to(to: Vector2):
	_is_auto_replace_on = true
	expected_position = to

# <> signal section <>
func _on_clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_is_auto_replace_on = false
			WorldContext.click_on_object.emit(self)
