extends CharacterState

enum ChargeType{
	InsufficientCharge,
	HalfCharge, 
	FullCharge, 
	OverCharge
}

export (ChargeType) var chargeType = ChargeType.InsufficientCharge

func _frame_0():
	print("lol")
	$"%ExcaliburChargeUp".start_emitting()
	
#func _frame_20():
#	$"%ExcaliburChargeUp".stop_emitting()
