extends ObjectState

var hit_something = false

func _frame_0():
	if host.get_facing_int() == -1:
		host.sprite.flip_h = true

func _tick():
	if not hit_something:
		host.move_directly(8 * host.get_facing_int(),0)
		
func _frame_30():
	hit_something = true
	host.disable()
	
func _on_hit_something(obj,hitbox):
	._on_hit_something(obj,hitbox)
	hit_something = true
	host.disable()
