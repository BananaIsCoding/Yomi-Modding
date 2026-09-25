extends CharacterState
	
class_name CommandSpellState

onready var cutscene = $"%CommandSealCutscene"
onready var cutsceneFiller = $"%CutsceneFiller"
onready var textBox = $"%CommandEmoteLabel"

export var _c_StanceStuff = 0
export (String) var normal_StateAnimName
export (String) var normalArmour_StateAnimName
export (String) var hiddenArmour_StateAnimName
export (String) var hidden_StateAnimName

export var _c_CutsceneStuff = 0
export var cutsceneTPF := 4

var cutsceneDuration := 0
var currentStateTick := 0
var cutscenePlaying := false
var cutsceneFrameLength = 0
var emoteTimer := 0
var emoting = false
var emotePart2 = false

func _frame_0():
	match host.stance:
		"Normal":
			anim_name = normal_StateAnimName
		"Normal(Armour)":
			anim_name = normalArmour_StateAnimName
		"Hidden":
			anim_name = hidden_StateAnimName
		"Hidden(Armour)":
			anim_name = hiddenArmour_StateAnimName
	
	# Set up for cutscene 
	host.quick_ui_hider()
	
	host.grab_camera_focus()
	host.set_camera_zoom(1.0)
	
	match host.commandSeals:
		3:
			cutscene.animation = "default"
		2:
			cutscene.animation = "SecondTime"
		1: 
			cutscene.animation = "ThirdTime"
	
	cutsceneFrameLength = cutscene.frames.get_frame_count(cutscene.animation)
	cutsceneDuration = cutsceneFrameLength * cutsceneTPF

	cutscene.show()
	currentStateTick = 0
	cutscene.frame = 0
	cutsceneFiller.show()
	cutscenePlaying = true
	
	host.cutsceneInProgress = true
	
	textBox.clear()
	textBox.append_bbcode("[center]" + "On My Command Spell")
	textBox.visible_characters = 0
	textBox.percent_visible = 0
	textBox.modulate.a = 1.0
	emoting = true
	emoteTimer = 0


func _tick():
	
	if cutscenePlaying:
		if current_tick != 0 and cutsceneDuration > 0:
			if not host.is_ghost:
				Global.current_game.time += 1
			cutsceneDuration -= 1
			current_tick -= 1
		
		host.opponent.hitlag_ticks += 1
		# Ensure cutscene is correctly 
		host.set_camera_zoom(1.0)
		host.grab_camera_focus()
		
		# To change cutscene frame every x ticks
		currentStateTick += 1
		if currentStateTick % cutsceneTPF == 0:
			cutscene.frame += 1
			if cutscene.frame >= cutsceneFrameLength - 1:
				EndCutscene()
				DoCommandSpell()
	
				if host.is_ghost:
					Network.game.get_player(host.id).playerExtra.PreviewSealUsage()
				else:
					host.UseCommandSeal()
					
		if textBox.bbcode_text != "":
			emoting = true
		if emoting:
			if textBox.percent_visible < 1.0:
				if currentStateTick % 5 == 0:
					textBox.visible_characters += host.randi_range(1, 2)
					#play_sound("Dialogue")
			else:
				emoteTimer += 1
			if emoteTimer >= 50:
				textBox.modulate.a = lerp(textBox.modulate.a, 0.0, 0.12)
			if emoteTimer > 90:
				textBox.percent_visible = 0.0
				textBox.visible_characters = 0
				textBox.hide()
				textBox.bbcode_text = ""
				emoting = false
				emoteTimer = 0

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

func DoCommandSpell():
	pass
	
func _exit():
	._exit()
	EndCutscene()
	

func EndCutscene():
	host.cutsceneInProgress = false
	cutscenePlaying = false
	cutscene.hide()
	cutsceneFiller.hide()
	host.quick_ui_revealer()
	host.release_camera_focus()
	
func is_usable():
	return host.commandSeals > 0 and .is_usable()
