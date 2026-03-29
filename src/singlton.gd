# Global class for saving shared data
extends Node

var time_season = Enums.TimeSeasons.DAY

signal click_on_object(entity: Entity)
signal energy_shed(position: Vector2, impulse: float, energy: int)
signal fission(parent: Entity)
signal remove_object(entity: Entity)
