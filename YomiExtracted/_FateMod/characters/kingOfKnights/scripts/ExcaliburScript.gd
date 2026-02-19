extends KokNormalAttackState

func _enter():
	$"%ExcaliburChargeUp".start_emitting()

func _exit():
	$"%ExcaliburChargeUp".stop_emitting()

