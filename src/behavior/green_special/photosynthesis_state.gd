class_name PhotosynthesisState
extends RefCounted

func update(bacteria: Bacterium):
	if Singlton.time_season == Enums.TimeSeasons.Night:
		bacteria.behavior_state = StateMachine.energy_recycle

func do_task(bacteria: Bacterium):
	bacteria.photosynthesing()
