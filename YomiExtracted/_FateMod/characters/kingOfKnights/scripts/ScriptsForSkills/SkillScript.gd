extends CharacterState
	
class_name SkillState

var cutscene = false
var prevHitLag

func _enter():
	host.grab_camera_focus()
	host.tween_camera_zoom(0.99, 0.40, 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	if host.is_ghost:
		anim_name = ""
	prevHitLag = host.opponent.hitlag_ticks
	cutscene = true

func _frame_24():
	host.set_camera_zoom(0.40)
	host.tween_camera_zoom(0.40, 0.99, 0.75, Tween.TRANS_QUART, Tween.EASE_OUT)

func _exit():
	host.release_camera_focus()
	cutscene = false
	host.opponent.hitlag_ticks = prevHitLag
	#host.skillCd = 300
	
func _tick():
	if cutscene:
		host.opponent.hitlag_ticks = 1
