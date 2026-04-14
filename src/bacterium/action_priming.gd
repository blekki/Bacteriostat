class_name ActionPriming
extends Timer

# priming codes
const FINISHED: bool = true
const IN_PROCESS: bool = false
# other
const _NO_ACTION = "WAITING"

var _action: String = _NO_ACTION

## Run action priming. If an action changed, a timer restarts. Return [true] if the timer time out.
func try_process(duration_sec: float, active_action: String) -> bool:
	if not self.is_stopped():
		return IN_PROCESS
	
	if _action == active_action:
		_action = _NO_ACTION
		return FINISHED
	
	# run new tmer iteration
	_action = active_action
	self.start(duration_sec)
	return IN_PROCESS

func is_active():
	return not is_stopped()

# <> need to quick getting information <>
func get_remaining_time() -> float:
	return self.time_left

func get_action() -> String:
	if is_stopped():
		return _NO_ACTION
	else:
		return _action
