@tool
@icon("not_guard.svg")
## A guard which is satisfied when the given guard is not satisfied.
class_name NotGuard
extends Guard

## The guard that should not be satisfied. When null, this guard is always satisfied.
@export var guard: Guard

func is_satisfied(context_transition:Transition, context_state:State) -> bool:
	if guard == null:
		return true
	return not guard.is_satisfied(context_transition, context_state)
