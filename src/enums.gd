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
