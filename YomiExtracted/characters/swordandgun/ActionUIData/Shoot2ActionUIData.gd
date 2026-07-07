extends ActionUIData
onready var di_label = $Direction / Control / Control / Label2
onready var direction = $Direction
onready var activate_temporal = $ActivateTemporal
onready var holster = $Holster

func fighter_update():
	di_label.rect_position.x = abs(di_label.rect_position.x) * - 1 if fighter.id == 1 else 1

	holster.set_pressed_no_signal(true)

func get_data():
	return {
		"x": direction.get_data().x, 
		"y": direction.get_data().y, 

		"holster": holster.pressed, 
	}
