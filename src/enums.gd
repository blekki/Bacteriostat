class_name Enums
extends RefCounted

enum TimeSeasons {
	DAY,
	NIGHT,
}

enum RelationshipTypes {
	NONE,
	CELL,
	PREY,
	NEUTRAL,
	PREDATOR,
}

const DEBUG_RELATIONSHIP_COLORS: Dictionary = {
	RelationshipTypes.NONE: Color.DIM_GRAY,
	RelationshipTypes.CELL: Color.YELLOW,
	RelationshipTypes.PREY: Color.MEDIUM_SPRING_GREEN,
	RelationshipTypes.NEUTRAL: Color.LIGHT_GRAY,
	RelationshipTypes.PREDATOR: Color.RED,
}
