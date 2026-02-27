class_name EnergyCell
extends CharacterBody2D

var cell_name: String = "Unknown"
var type: Enums.EnergyCellTypes
var energy_equivalent: int = 0		# how much energy contains

func _physics_process(delta: float):
	_deceleration()
	_collision_fluence()
	move_and_slide()

# <> need for identification "get" methods <>
func get_cell_type() -> Enums.EnergyCellTypes:
	return type

func get_pos() -> Vector2:
	return position

# other methods
func _deceleration():
	const DECELERATION: float = 2
	if velocity.length() > DECELERATION:
		velocity -= velocity.normalized() * DECELERATION
	else:
		velocity = Vector2.ZERO

func _collision_fluence():
	const COLLISION_DEFLECTION: float = 5.0
	var collision
	if get_slide_collision_count() > 0:
		collision = get_slide_collision(0)
	if collision:
		var collider = collision.get_collider()		# todo: fix unsync fluence
		velocity += collision.get_normal() * (COLLISION_DEFLECTION)

func _on_clickable_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed:
		Singlton.energy_cell_clicked.emit(self)
