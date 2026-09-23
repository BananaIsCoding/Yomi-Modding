extends PlayerExtra

onready var tips = $TipToggle
onready var commandSealUI = $CommandSealUI

func _ready():
	tips.connect("toggled", self, "_on_tips_toggled")
	if fighter.id == 2:
		move_child(commandSealUI, get_child_count() - 1)
		commandSealUI.flip_h = true
		commandSealUI.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/CommandSpellUIP2.png")
		#move_child($CommandSealGap, get_child_count() - 2)

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
