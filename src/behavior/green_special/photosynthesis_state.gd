class_name PhotosynthesisState
extends RefCounted

func update(bacteria: Bacteria):
	if Singlton.time_season == Enums.TimeSeasons.Night:
		bacteria.behavior_state = StateMachine.energy_recycle

func do_task(bacteria: Bacteria):
	bacteria.photosynthesing()
