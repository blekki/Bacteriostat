# Global class for saving shared data
extends Node

var season_continues: float = 0.0
var season_duration: float = 0.0
var time_season = Enums.TimeSeasons.DAY

signal click_on_object(entity: Entity)
signal energy_shed(position: Vector2, impulse: float, energy: int)
signal fission(parent: Bacterium)
signal remove_object(entity: Entity)
