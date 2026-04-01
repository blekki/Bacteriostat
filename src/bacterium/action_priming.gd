class_name ActionPriming
extends Timer

const _FINISHED: bool = true
const _IN_PROCESS: bool = false
const _NO_ACTION = ""

var _action: String = _NO_ACTION

## Run action priming. If an action changed, a timer restarts. Return [true] if the timer time out.
func try_process(duration_sec: float, active_action: String) -> bool:
	if not self.is_stopped():
		return _IN_PROCESS
	
	if _action == active_action:
		_action = _NO_ACTION
		return _FINISHED
	
	_action = active_action
	self.start(duration_sec)
	return _IN_PROCESS

# <> need to quick get info <>
func get_remaining_time() -> float:
	return self.time_left

func get_action() -> String:
	return _action
