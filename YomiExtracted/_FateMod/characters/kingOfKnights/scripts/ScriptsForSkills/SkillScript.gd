extends CharacterState
	
class_name SkillState

func _enter():
	host.grab_camera_focus()
	host.tween_camera_zoom(0.99, 0.40, 0.65, Tween.TRANS_QUART, Tween.EASE_OUT)
	if host.is_ghost:
		anim_name = ""

func _frame_11():
	host.set_camera_zoom(0.40)
	host.tween_camera_zoom(0.40, 0.99, 0.65, Tween.TRANS_QUART, Tween.EASE_OUT)
	
func _exit():
	host.skillCd = 300
