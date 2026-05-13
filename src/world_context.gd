# Global class for saving shared data
extends Node

var time_season = Enums.TimeSeasons.DAY
var season_continues: float = 0.0
var season_duration: float = 0.0

signal click_on_object_debug(entity: CharacterBody2D)
signal click_on_object(entity: CharacterBody2D)
signal energy_shed(position: Vector2, impulse: Vector2, energy: int)
signal fission(parent: Bacterium)
signal remove_object(entity: Entity)

func is_day() -> bool:
	return time_season == Enums.TimeSeasons.DAY

func is_night() -> bool:
	return time_season == Enums.TimeSeasons.NIGHT

func get_season_info() -> String:
	var current_season: String = "day" if is_day() else "night"
	var text: String = "%.1f/%d (%s)" % [season_continues, season_duration, current_season]
	return text
