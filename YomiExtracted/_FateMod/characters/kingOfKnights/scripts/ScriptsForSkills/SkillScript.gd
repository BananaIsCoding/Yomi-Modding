extends CharacterState
	
class_name SkillState

func _enter():
	
	host.grab_camera_focus()
	host.tween_camera_zoom(0.99, 0.40, 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	if host.is_ghost:
		anim_name = ""
	
func _exit():
	host.set_camera_zoom(0.40)
	host.tween_camera_zoom(0.40, 0.99, 2, Tween.TRANS_QUART, Tween.EASE_OUT)
	host.skillCd = 300
