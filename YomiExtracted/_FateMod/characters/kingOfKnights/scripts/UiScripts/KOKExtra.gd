extends PlayerExtra

onready var tips = $TipToggle
onready var commandSealUI = $CommandSealUI

export var spriteWidth := 35
export var spriteHeight := 64

var sealAnimateTexture 
var theSealAtlas

func _ready():
	tips.connect("toggled", self, "_on_tips_toggled")
	sealAnimateTexture = AnimatedTexture.new()
	sealAnimateTexture.frames = 2
	if fighter.id == 2:
		move_child(commandSealUI, get_child_count() - 1)
		commandSealUI.flip_h = true
		var newAtlas = AtlasTexture.new()
		newAtlas.atlas = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/P2CommandSpellSS.png")
		newAtlas.region = Rect2(spriteWidth * fighter.commandSeals, 0, spriteWidth, spriteHeight)
		commandSealUI.texture = newAtlas

func _on_tips_toggled(_on):
	emit_signal("data_changed")

func get_extra():
	return {
		"Tips" : tips.pressed and tips.visible
	}

func show_options():
	tips.show() if (fighter.stance == "Hidden" or fighter.stance == "Hidden(Armour)") else tips.hide()

func reset():
	tips.set_pressed_no_signal(tips.pressed)

func PreviewSealUsage():
	theSealAtlas = commandSealUI.texture
	commandSealUI.texture = sealAnimateTexture
	sealAnimateTexture.set_frame_texture(0, theSealAtlas)
	var newRect = theSealAtlas.region
	newRect.position.x -= spriteWidth 
	theSealAtlas.region = newRect
	sealAnimateTexture.set_frame_texture(1, theSealAtlas)

func UpdateCommandSeals(numOfSeals : int):
	commandSealUI.texture = theSealAtlas
	commandSealUI.texture.region = Rect2(spriteWidth * numOfSeals, 0, spriteWidth, spriteWidth)
