extends CharacterState

func _frame_0():
	host.opponent.hitlag_ticks += 15
	host.play_sound("RoseMeurOpen")
	host.play_sound("RoseMeurOpen2")
	host.set_camera_zoom(0.50)
	host.tween_camera_zoom(0.99, 0.50, 0.65, Tween.TRANS_QUART, Tween.EASE_OUT)
	$"%BloodWings".hide()

func _frame_10():
	if data:
		var temp = host.spawn_object(load("res://Cataclysm/characters/Cataclysm/Projectile1.tscn"), data.x*3, 0)
		temp.set_pos(temp.get_pos().x, 0)
		temp.set_facing(host.get_facing_int())
	
func _frame_17():
	host.play_sound("RoseMeurImpact")
	host.set_camera_zoom(0.20)
	host.tween_camera_zoom(0.60, 0.20, 0.50, Tween.TRANS_QUART, Tween.EASE_OUT)
	host.spawn_bloodpool(data.x*3, 0)

func _frame_26():
	host.set_camera_zoom(1.00)
	host.tween_camera_zoom(0.18, 1.00, 0.50, Tween.TRANS_QUART, Tween.EASE_OUT)

func _exit():
	$"%BloodWings".start_emitting()
	if host.bloodfeast > 40:
		$"%bloodfeast".start_emitting()
	if host.bloodfeast < 40:
		$"%bloodfeast".stop_emitting()
	host.set_camera_zoom(1.00)
	host.tween_camera_zoom(1.00, 1.00, 0.50, Tween.TRANS_QUART, Tween.EASE_OUT)

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	if obj == host.get_opponent():
		host.bloodfeast += 10
