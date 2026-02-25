class_name EnergyRecycleState
extends RefCounted

func update(bacterium: Bacterium):
	if Singlton.time_season == Enums.TimeSeasons.DAY:
		bacterium.behavior_state = StateMachine.photosynthesis

func do_task(bacterium: Bacterium):
	bacterium.recycle_energy()
