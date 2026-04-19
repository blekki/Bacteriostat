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
	RelationshipTypes.NONE: Color(0.0, 0.0, 0.0, 0.157),
	RelationshipTypes.LURE: Color(1.0, 1.0, 0.0, 1.0),
	RelationshipTypes.PREY: Color(0.0, 1.0, 0.408, 1.0),
	RelationshipTypes.PREDATOR: Color(1.0, 0.0, 0.085, 1.0),
}
