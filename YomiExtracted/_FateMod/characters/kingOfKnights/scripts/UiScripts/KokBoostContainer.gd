extends PlayerInfo

export (PackedScene) var BoostInfoScene
export (int) var slotOffsetBoxes = 1 
onready var boostBoxContainer = $"%HFlowContainer"
onready var parentContainer = $"%HBoxContainer"
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
		
		var gapBlock = BoostInfoScene.instance()
		
		if player_id == 2:
			parentContainer.add_child_below_node(gapBlock, boostBoxContainer)
			$"%HBoxContainer".alignment = BoxContainer.ALIGN_END
			# could do recursive if it get longer than 5 per row
			CreateReverseSlotRow()
#			boostBoxContainer.add_child(mainBuffSlot)
#			AddFillerBoxes()
#			return
#		else:
#			parentContainer.add_child(gapBlock)
#			parentContainer.move_child(gapBlock, 0)
		
#		AddFillerBoxes()
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
		if amountOfBuff % 5 == 0:
			var newBoost = BoostInfoScene.instance()
			newBoost.texture = imagePath
			newBoost.hint_tooltip = toolTip
			listOfBoostInstance.append(newBoost)
			
			CreateReverseSlotRow()
			
			boostBoxContainer.add_child(newBoost)
			
#			AddFillerBoxes()
			
			amountOfBuff += 1
			return newBoost
		else:
			listOfBoostInstance[amountOfBuff].texture = imagePath
			listOfBoostInstance[amountOfBuff].hint_tooltip = toolTip
			amountOfBuff += 1
			return listOfBoostInstance[amountOfBuff - 1]
	else:
#		if amountOfBuff % 5 == 0:
#			AddFillerBoxes()
		var newBoost = BoostInfoScene.instance()
		newBoost.texture = imagePath
		newBoost.hint_tooltip = toolTip
		boostBoxContainer.add_child(newBoost)
		amountOfBuff += 1
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

func CreateReverseSlotRow():
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
	
	createdRows += 1

func AddFillerBoxes():
	
	for count in range(slotOffsetBoxes):
		var fillerBox = BoostInfoScene.instance()
		boostBoxContainer.add_child(fillerBox)
