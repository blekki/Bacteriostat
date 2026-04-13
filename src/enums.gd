class_name Enums
extends RefCounted

enum TimeSeasons {
	DAY,
	NIGHT,
}

enum RelationshipTypes {
	NONE,
	LURE,
	PREY,
	PREDATOR,
}

const DEBUG_RELATIONSHIP_COLORS: Dictionary = {
	RelationshipTypes.NONE: Color.DIM_GRAY,
	RelationshipTypes.LURE: Color.YELLOW,
	RelationshipTypes.PREY: Color.MEDIUM_SPRING_GREEN,
	RelationshipTypes.PREDATOR: Color.RED,
}
