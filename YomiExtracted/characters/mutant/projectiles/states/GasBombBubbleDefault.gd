extends ObjectState
onready var hitbox = $Hitbox
var no_juke_pips = true

func _on_hit_something(obj, hitbox):
	queue_state_change("Pop")
	

func _tick():
	if host.get_fighter().is_in_hurt_state(false) and not host.get_opponent().current_state().get("IS_BURST"):
		queue_state_change("Pop")
