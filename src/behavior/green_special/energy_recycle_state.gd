class_name EnergyRecycleState
extends RefCounted

func update(bacteria: Bacterium):
	if Singlton.time_season == Enums.TimeSeasons.Day:
		bacteria.behavior_state = StateMachine.photosynthesis

func do_task(bacteria: Bacterium):
	bacteria.recycle_energy()
