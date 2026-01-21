
extends CharacterState

export (PackedScene) var SlashProjectile
# Temp for now (will be replaced by UI Data)
export var projPosX = 0
export var projPosY = 0


func _frame_5():
	host.spawn_object(SlashProjectile, projPosX, projPosY)
