extends PlayerExtra

onready var tips = $TipToggle
onready var commandSealUI = $CommandSealUI

export var spriteWidth := 35
export var spriteHeight := 64

var currentSpriteRegion
var nextSpriteRegion
var previewMode := false
var isCurrentSprite := true
var tick = 0
var isAvalon := false


func _ready():
	tips.connect("toggled", self, "_on_tips_toggled")
	
	if fighter.id == 2:
		move_child(commandSealUI, get_child_count() - 1)
		commandSealUI.flip_h = true
		var newAtlas = AtlasTexture.new()
		newAtlas.atlas = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/P2CommandSpellSS.png")
		newAtlas.region = Rect2(spriteWidth * fighter.commandSeals, 0, spriteWidth, spriteHeight)
		commandSealUI.texture = newAtlas
	
	currentSpriteRegion = commandSealUI.texture.region
	fighter.playerExtra = self

func _on_tips_toggled(_on):
	emit_signal("data_changed")

func get_extra():
	return {
		"Tips" : tips.pressed and tips.visible
	}

func show_options():
	tips.show() if (fighter.stance == "Hidden" or fighter.stance == "Hidden(Armour)" or isAvalon or fighter.avalonObj != null) and not fighter.busy_interrupt else tips.hide()

func reset():
	tips.set_pressed_no_signal(tips.pressed)

func PreviewSealUsage():
	
	if previewMode:
		return
	
	nextSpriteRegion = currentSpriteRegion
	nextSpriteRegion.position.x -= spriteWidth 
	
	previewMode = true

func UpdateCommandSeals(numOfSeals : int):
	isCurrentSprite = true
	previewMode = false
	currentSpriteRegion = Rect2(spriteWidth * numOfSeals, 0, spriteWidth, spriteHeight)
	commandSealUI.texture.region = currentSpriteRegion

func _process(delta):
	
	if previewMode:
		tick += 1
		if tick >= 30:
			tick = 0
			if isCurrentSprite:
				commandSealUI.texture.region = nextSpriteRegion
			else:
				commandSealUI.texture.region = currentSpriteRegion
			
			isCurrentSprite = !isCurrentSprite 

func update_selected_move(move_state):
	isCurrentSprite = true
	commandSealUI.texture.region = currentSpriteRegion
	previewMode = false
	isAvalon = false
	fighter.HideHintText()
	.update_selected_move(move_state)
