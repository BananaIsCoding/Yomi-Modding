extends PlayerExtra

onready var tips = $TipToggle

func _ready():
	tips.connect("toggled", self, "_on_tips_toggled")

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
