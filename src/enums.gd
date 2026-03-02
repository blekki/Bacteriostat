class_name Enums
extends RefCounted

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

enum TimeSeasons {
	DAY,
	NIGHT,
}

enum ObjectTypes {
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
const DEBUG_OBJECT_COLORS = {
	ObjectTypes.NONE: Color.DIM_GRAY,
	ObjectTypes.INEDIBLE: Color.GRAY,
	ObjectTypes.EDIBLE: Color.MEDIUM_SPRING_GREEN,
	ObjectTypes.PRAY: Color.YELLOW,
	ObjectTypes.NEUTRAL: Color.GREEN,
	ObjectTypes.ENEMY: Color.RED,
}
