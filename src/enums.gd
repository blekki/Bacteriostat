class_name Enums
extends RefCounted

enum TimeSeasons {
	DAY,
	NIGHT,
}

enum BacteriumTypes {
	NONE,
	GREEN,
	PURPLE,
	ORANGE,
	DEFAULT = GREEN,
}

enum EnergyCellTypes {
	NONE,
	GRASS,
	MEAT,
}

enum RelationshipTypes {
	NONE,
	# only cells
	INEDIBLE,
	EDIBLE,
	# only bacteria
	PRAY,
	NEUTRAL,
	ENEMY,
}

# dictionary
const DEBUG_RELATIONSHIP_COLORS = {
	RelationshipTypes.NONE: Color.DIM_GRAY,
	RelationshipTypes.INEDIBLE: Color.GRAY,
	RelationshipTypes.EDIBLE: Color.MEDIUM_SPRING_GREEN,
	RelationshipTypes.PRAY: Color.YELLOW,
	RelationshipTypes.NEUTRAL: Color.GREEN,
	RelationshipTypes.ENEMY: Color.RED,
}

}
