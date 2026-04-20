# Class for objects physic declaration
class_name Entity
extends CharacterBody2D

# > pixel/physic_frame
const PASSIVE_DECELERATION: float = 1.0

@export var entity_name: String = "Raw Entity"
@export var energy: int = 50	# equivalent to health
@export var min_energy: int = 0
@export var max_energy: int = 100

# technical var's
var debug_layer: int = -1	# [-1] is as "nothing" code
var _navigation_field_x1y1: Vector2 = Vector2.ZERO
var _navigation_field_x2y2: Vector2 = Vector2.ZERO
var _random: RandomNumberGenerator = RandomNumberGenerator.new()

# <> Methods section <>
## Need to correct work of the object number generator
func setup_nav_field(from: Vector2, to: Vector2):
	_navigation_field_x1y1 = from
	_navigation_field_x2y2 = to

func _ready():
	_random.randomize()
	debug_layer = Debug.get_new_layer()
	position = _generate_smart_point()

func _process(_delta: float):
	_update_lumi_texture()

func _physics_process(_delta: float):
	_deceleration()
	_collision_fluence()
	move_and_slide()

func set_physics_updating(enable: bool):
	set_physics_process(enable)

func _generate_smart_point() -> Vector2:
	var point = Vector2(
		_random.randf_range(_navigation_field_x1y1.x, _navigation_field_x2y2.x),	# x
		_random.randf_range(_navigation_field_x1y1.y, _navigation_field_x2y2.y)		# y
	)
	return point

func _deceleration():
	if velocity.length() > PASSIVE_DECELERATION:
		velocity -= velocity.normalized() * PASSIVE_DECELERATION
	else:
		velocity = Vector2.ZERO

func _collision_fluence():
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var collider  = collision.get_collider()
		var normal    = collision.get_normal()
		
		var v1  = self.velocity
		var v2  = collision.get_collider_velocity()
		var dot = (v1 + v2).dot(normal)
		
		self.velocity += -dot * normal			# lose momentum
		if collider is Entity:					# is moveble object
			collider.velocity += dot * normal	# get momentum

func _update_lumi_texture():
	var lumi: Sprite2D = $Lumi
	var alpha: float = lumi.self_modulate.a
	const WEIGHT: float = 0.1
	if Singlton.is_day():
		alpha = lerp(alpha, 0.0, WEIGHT) # off lumi 
	else: 
		alpha = lerp(alpha, 1.0, WEIGHT) # on lumi
	lumi.self_modulate.a = alpha

func get_personal_name() -> String:
	return entity_name

func get_texture() -> Texture2D:
	return $Texture.texture

func get_info() -> String:
	var information: String = "energy: %d/%d\n" % [energy, max_energy]
	return information

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
	Debug.remove_layer(debug_layer)
	Singlton.remove_object.emit(self)

# <> reaction on signals section <>
func _on_clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Singlton.click_on_object.emit(self)
