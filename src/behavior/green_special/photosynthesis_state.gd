class_name PhotosynthesisState
extends RefCounted

func update(bacterium: Bacterium):
	#if Singlton.time_season == Enums.TimeSeasons.Night:
		#bacterium.behavior_state = StateMachine.energy_recycle
	
	if bacterium.energy >= bacterium.OVERAGE_ENERGY_LIMIT:
		bacterium.behavior_state = StateMachine.shadding

func do_task(bacterium: Bacterium):
	bacterium.photosynthesing()
