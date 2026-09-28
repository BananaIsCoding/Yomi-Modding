extends CharacterState

export (int) var avalonDurationTick := 60

onready var avalonIconPng = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/Avalon.png")

func spawn_exported_projectile():
	if projectile_scene:
		var pos = get_projectile_pos()
		var projData = {
			"AnchorPos" : Vector2(projectile_pos_x, projectile_pos_y),
			"Character" : host
		}
		var obj = host.spawn_object(projectile_scene, pos.x, pos.y, true, projData, projectile_local_pos)
		process_projectile(obj)
		
		if not host.is_ghost:
			var newItem = host.BoostData.new()
			newItem.boostType = host.BoostType.Avalon
			newItem.tickRemaining = avalonDurationTick
			var newToolTip = "- Passive Regen\n- Chance For Hyper Armour\n( " + str(avalonDurationTick) + " ticks )"
			newItem.instance = host.BoostInfoUiInstance.AddBoost(avalonIconPng, newToolTip)
			host.BoostQueue.append(newItem)
		
		host.avalonObj = obj
