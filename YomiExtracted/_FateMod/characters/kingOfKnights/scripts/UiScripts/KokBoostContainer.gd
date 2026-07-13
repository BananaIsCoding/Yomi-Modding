extends PlayerInfo

export (PackedScene) var BoostInfoScene
onready var boostBoxContainer = $"%HFlowContainer"
onready var mainBuffSlot

var createdRows = 0
var amountOfBuff = 1

var listOfBoostInstance = []

func set_fighter(fighter):
	.set_fighter(fighter)
	fighter.BoostInfoUiInstance = self
		
func _ready():
	yield(get_tree(), "idle_frame") 
	
	if is_instance_valid(fighter):
		
		mainBuffSlot = BoostInfoScene.instance()
		listOfBoostInstance.append(mainBuffSlot)
		mainBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/AttackSpeedBuff.png")
		mainBuffSlot.hint_tooltip = "+1 Frame Advantage"
		
		if player_id == 2:
			$"%HBoxContainer".alignment = BoxContainer.ALIGN_END
			# could do recursive if it get longer than 5 per row
			var forthBox = BoostInfoScene.instance()
			var thirdBox = BoostInfoScene.instance()
			var secondBox = BoostInfoScene.instance()
			var firstBox = BoostInfoScene.instance()
			
			listOfBoostInstance.append(forthBox)
			listOfBoostInstance.append(thirdBox)
			listOfBoostInstance.append(secondBox)
			listOfBoostInstance.append(firstBox)

			boostBoxContainer.add_child(firstBox)
			boostBoxContainer.add_child(secondBox)
			boostBoxContainer.add_child(thirdBox)
			boostBoxContainer.add_child(forthBox)

			createdRows = 1

		boostBoxContainer.add_child(mainBuffSlot)	

func _process(delta):
	if is_instance_valid(fighter):
		pass
	
func ChangeMainBuff():
	var currentStance = fighter.stance
	if currentStance == "Normal":
		mainBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/AttackSpeedBuff.png")
		mainBuffSlot.hint_tooltip = "+1 Frame Advantage" 
	elif currentStance == "Normal(Armored)":
		mainBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/DefenceBuff.png")
		mainBuffSlot.hint_tooltip = "+10% Damage Reduction"
	elif currentStance == "Alter":
		mainBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/NormalAttackUp.png")
		mainBuffSlot.hint_tooltip = "+20% Damage Boost"
		
func AddBoost(imagePath, toolTip):
	if createdRows > 0:
		print ("1) Ammount of boost:",amountOfBuff)
		if amountOfBuff % 5 == 0:
			var newBoost = BoostInfoScene.instance()
			newBoost.texture = imagePath
			newBoost.hint_tooltip = toolTip
			listOfBoostInstance.append(newBoost)
			
			var forthBox = BoostInfoScene.instance()
			var thirdBox = BoostInfoScene.instance()
			var secondBox = BoostInfoScene.instance()
			var firstBox = BoostInfoScene.instance()
			
			listOfBoostInstance.append(forthBox)
			listOfBoostInstance.append(thirdBox)
			listOfBoostInstance.append(secondBox)
			listOfBoostInstance.append(firstBox)
			
			
			boostBoxContainer.add_child(firstBox)
			boostBoxContainer.add_child(secondBox)
			boostBoxContainer.add_child(thirdBox)
			boostBoxContainer.add_child(forthBox)
			boostBoxContainer.add_child(newBoost)
			
			createdRows += 1
			amountOfBuff += 1
			return newBoost
		else:
			print ("2) Ammount of boost:",amountOfBuff)
			listOfBoostInstance[amountOfBuff].texture = imagePath
			listOfBoostInstance[amountOfBuff].hint_tooltip = toolTip
			amountOfBuff += 1
			return listOfBoostInstance[amountOfBuff - 1]
	else:
		print ("3) Ammount of boost:",amountOfBuff)
		var newBoost = BoostInfoScene.instance()
		newBoost.texture = imagePath
		newBoost.hint_tooltip = toolTip
		boostBoxContainer.add_child(newBoost)
		return newBoost

func RemoveBoost(boostInstance):
	for index in range(listOfBoostInstance.size()):
		if listOfBoostInstance[index] == boostInstance:
			for i in range (index, amountOfBuff - 1):
				listOfBoostInstance[i] = listOfBoostInstance[i + 1]
			amountOfBuff -= 1
			listOfBoostInstance[amountOfBuff].texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/EmptySlot.png")
			listOfBoostInstance[amountOfBuff].hint_tooltip = ""
			break
		index += 1
