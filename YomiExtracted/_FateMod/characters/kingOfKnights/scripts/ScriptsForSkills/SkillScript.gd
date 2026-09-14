extends CharacterState
	
class_name SkillState

export (String) var normal_StateAnimName
export (String) var normalArmour_StateAnimName
export (String) var hiddenArmour_StateAnimName
export (String) var hidden_StateAnimName

var cutscene = false
var prevHitLag

func _enter():
	host.grab_camera_focus()
	host.tween_camera_zoom(0.99, 0.40, 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	if host.is_ghost:
		anim_name = ""
	prevHitLag = host.opponent.hitlag_ticks
	cutscene = true
	
	match host.stance:
		"Normal":
			anim_name = normal_StateAnimName
		"Normal(Armour)":
			anim_name = normalArmour_StateAnimName
	
func _ready():
	if (normal_StateAnimName == ""):
		normal_StateAnimName = sprite_animation
	if (normalArmour_StateAnimName == ""):
		normalArmour_StateAnimName = normal_StateAnimName + "(Armour)"
	if (hiddenArmour_StateAnimName == ""):
		hiddenArmour_StateAnimName = normal_StateAnimName + "(HiddenArmour)"
	if (hidden_StateAnimName == ""):
		hidden_StateAnimName = normal_StateAnimName + "(Hidden)"
	._ready()

func _frame_24():
	host.set_camera_zoom(0.40)
	host.tween_camera_zoom(0.40, 0.99, 0.75, Tween.TRANS_QUART, Tween.EASE_OUT)

func _exit():
	if not host.is_ghost:
		print(name, ": ", Global.current_game.current_tick)
	host.release_camera_focus()
	cutscene = false
	host.opponent.hitlag_ticks = prevHitLag
	#host.skillCd = 300
	
func _tick():
	if cutscene:
		host.opponent.hitlag_ticks = 1
