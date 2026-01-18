extends PlayerInfo

func set_fighter(fighter):
	.set_fighter(fighter)
	if player_id == 2:
		$HBoxContainer.alignment = BoxContainer.ALIGN_END
		call_deferred("update_p2")

func _process(delta):
	if is_instance_valid(fighter):
		$HBoxContainer/TextureRect/Label.text = str(fighter.bloodfeast)
