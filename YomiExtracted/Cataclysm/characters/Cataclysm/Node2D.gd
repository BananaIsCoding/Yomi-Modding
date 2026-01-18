extends CharacterState

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	if obj == host.get_opponent():
		host.bloodfeast += 10

func _exit():
	if host.bloodfeast > 40:
		$"%bloodfeast".start_emitting()
	if host.bloodfeast < 40:
		$"%bloodfeast".stop_emitting()
