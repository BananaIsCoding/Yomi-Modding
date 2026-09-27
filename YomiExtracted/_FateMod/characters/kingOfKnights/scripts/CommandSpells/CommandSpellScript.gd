extends CharacterState
	
class_name CommandSpellState

onready var cutscene = $"%CommandSealCutscene"
onready var handImage = $"%CommandSealCutscene/Hand"
onready var cutsceneFiller = $"%CutsceneFiller"
onready var textBox = $"%CommandEmoteLabel"
onready var buffEffect = get_node(buffEffectPath)

export var _c_CustomParticles = 0
export (NodePath) var buffEffectPath

export var _c_StanceStuff = 0
export (String) var normal_StateAnimName
export (String) var normalArmour_StateAnimName
export (String) var hiddenArmour_StateAnimName
export (String) var hidden_StateAnimName

export var _c_CutsceneStuff = 0
export var cutsceneTPF := 3
export var dialogue = ["By My Command Seal"]
export var dialogueDuration = [50]
export var dialogueLetterPerFrame := 3
export var dialogueHideDuration = 25
export var servantDialogue = ""

var cutsceneDuration := 0
var currentStateTick := 0
var cutscenePlaying := false
var cutsceneFrameLength = 0
var emoteTimer := 0
var emoting = false
var dialogueIndex := 0

func _frame_0():
	# Changing Stance Based Off Stance
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
	
	if host.id == 2:
		handImage.texture = load("res://_FateMod/characters/kingOfKnights/sprites/CharacterSprites/P2HandForCSCutscene.png")
	
	# Change animation based on how many seals there are
	match host.commandSeals:
		3:
			cutscene.animation = "default"
		2:
			cutscene.animation = "SecondTime"
		1: 
			cutscene.animation = "ThirdTime"
	
	# Calculating the time to delay game for
	var estTimeForDialogue := 0
	for i in range(dialogue.size()):
		# Check if duration has been assigned to the phrase
		if dialogueDuration.size() < dialogue.size():
			dialogueDuration.append(50)
		estTimeForDialogue += (dialogue[i].length() * dialogueLetterPerFrame) + dialogueDuration[i]
	
	cutsceneFrameLength = cutscene.frames.get_frame_count(cutscene.animation)
	cutsceneDuration = (cutsceneFrameLength * cutsceneTPF) + estTimeForDialogue + dialogueHideDuration

	currentStateTick = 0
	cutscene.frame = 0
	cutscenePlaying = true
	host.cutsceneInProgress = true
	
	dialogueIndex = 0
	textBox.clear()
	textBox.append_bbcode("[center]" + dialogue[0])
	textBox.visible_characters = 0
	textBox.percent_visible = 0
	textBox.modulate.a = 1.0
	emoting = true
	emoteTimer = 0
	if host.is_ghost:
		Network.game.get_player(host.id).playerExtra.PreviewSealUsage()
	else:
		cutsceneFiller.show()
		cutscene.show()
		textBox.show()

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
		
		if textBox.bbcode_text != "":
			emoting = true
		if emoting:
			if textBox.percent_visible < 1.0:
				
				if currentStateTick % dialogueLetterPerFrame == 0:
					textBox.visible_characters += 1
					#play_sound("Dialogue")
			else:
				emoteTimer += 1
				if emoteTimer >= dialogueDuration[dialogueIndex]:
					if dialogueIndex < dialogue.size() - 1:
						emoteTimer = 0
						dialogueIndex += 1
						textBox.clear()
						textBox.modulate.a = 1.0
						textBox.bbcode_text = ""
						textBox.append_bbcode("[center]" + dialogue[dialogueIndex])
						textBox.percent_visible = 0.0
						textBox.visible_characters = 0
						currentStateTick = 0
					else:
						textBox.modulate.a = lerp(textBox.modulate.a, 0.0, 0.12)
				if emoteTimer > dialogueDuration[dialogueIndex] + dialogueHideDuration:
					emoteTimer = 0
					textBox.bbcode_text = ""
					textBox.percent_visible = 0.0
					textBox.visible_characters = 0
					textBox.hide()
					emoting = false
					currentStateTick = 0
		else:
			if currentStateTick % cutsceneTPF == 0:
				cutscene.frame += 1
				if cutscene.frame >= cutsceneFrameLength - 1:
					EndCutscene()
					DoCommandSpell()
					if not host.is_ghost:
						host.UseCommandSeal()
					if buffEffect != null:
						buffEffect.start_emitting()
					host.emote(servantDialogue)

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
