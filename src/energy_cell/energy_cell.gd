class_name EnergyCell
extends CharacterBody2D

var energy_equivalent: int = 0		# how much energy contains

func _physics_process(delta: float):
	_deceleration()
	_collision_fluence()
	move_and_slide()

func _deceleration():
	const DECELERATION: float = 2
	if velocity.length() > DECELERATION:
		velocity -= velocity.normalized() * DECELERATION
	else:
		velocity = Vector2.ZERO

func _collision_fluence():
	const COLLISION_DEFLECTION: float = 5.0
	var collision = get_slide_collision(0)
	if collision:
		var collider = collision.get_collider()		# todo: fix unsync fluence
		velocity += collision.get_normal() * (COLLISION_DEFLECTION)
