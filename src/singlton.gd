# Global class for saving shared data
extends Node

var time_season = Enums.TimeSeasons.DAY

#signal bacterium_clicked(bacterium: Bacterium)
#signal energy_cell_clicked(energy_cell: EnergyCell)
signal object_clicked(entity: Entity)
