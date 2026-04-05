class_name PurpleBacterium
extends Bacterium

# <> method section <>
func _init():
	# override var's
	bacterium_name = "Purple Bacterium"
	modulate = Color.PURPLE				# todo: change on texture
	behavior_state = StateMachine.get_start_purple_bacterium_state();

func _ready():
	super()

func _physics_process(delta: float):
	super(delta)

# <> behaviour dependencies <>
func swim_away(enemy_detection_radius: float):
	var identification_rules = func(object: Entity) -> Enums.RelationshipTypes:
		if Singlton.time_season == Enums.TimeSeasons.DAY:
			if object is OrangeBacterium:
				return Enums.RelationshipTypes.PREDATOR
		else: # if night is comming
			if object is GreenBacterium:
				return Enums.RelationshipTypes.PREDATOR
		# default
		return Enums.RelationshipTypes.NONE
	
	nearby_objects = get_nearby_objects(enemy_detection_radius, identification_rules)
	
	var predator_record: InfoPack = InfoUtils.get_nearest_predator(nearby_objects)
	if predator_record.object != null:
		var predator = predator_record.object
		
		const ESCAPE_DISTANCE: float = 140
		var direction_out_predator = (self.position - predator.position).normalized()
		var swim_to = self.position + direction_out_predator * ESCAPE_DISTANCE
		
		set_nav_target(swim_to)
		intercept_target(get_nav_target(), Vector2.ZERO)
		#intercept_target(get_nav_target(), predator_record.velocity)
	
