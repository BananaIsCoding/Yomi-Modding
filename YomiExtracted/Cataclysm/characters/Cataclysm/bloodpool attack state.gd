extends DefaultFireball

func _frame_0():
	$"%BlooDPoolAttack".start_emitting()
	host.play_sound("BloodPoolExplosion")
