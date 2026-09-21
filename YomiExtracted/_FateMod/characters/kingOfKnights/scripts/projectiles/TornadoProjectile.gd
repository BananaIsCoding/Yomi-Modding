extends BaseProjectile

func hit_by(hitbox):
	if hitbox.damage >= 50:
		disable()
		return
	.hit_by(hitbox)
