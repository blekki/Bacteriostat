class_name Enums
extends RefCounted

enum TimeSeasons {
	DAY,
	NIGHT,
}

enum RelationshipTypes {
	NONE,
	# only cells
	INEDIBLE,
	EDIBLE,
	# only bacteria
	PREY,
	NEUTRAL,
	PREDATOR,
}

const DEBUG_RELATIONSHIP_COLORS: Dictionary = {
	RelationshipTypes.NONE: Color.DIM_GRAY,
	RelationshipTypes.INEDIBLE: Color.GRAY,
	RelationshipTypes.EDIBLE: Color.MEDIUM_SPRING_GREEN,
	RelationshipTypes.PREY: Color.YELLOW,
	RelationshipTypes.NEUTRAL: Color.GREEN,
	RelationshipTypes.PREDATOR: Color.RED,
}
