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
		
		if player_id == 2:
			parentContainer.alignment = BoxContainer.ALIGN_END
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
	elif currentStance == "Normal(Armour)":
		mainBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/DefenceBuff.png")
		mainBuffSlot.hint_tooltip = "+10% Damage Reduction"
	elif currentStance == "Alter":
		mainBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/NormalAttackUp.png")
		mainBuffSlot.hint_tooltip = "+20% Damage Boost"
		
func AddBoost(imagePath, toolTip):
	print ("Adding: ", toolTip)
	if createdRows > 0:
		if amountOfBuff < listOfBoostInstance.size():
			print ("1) Ammount of boost:",amountOfBuff)
			listOfBoostInstance[amountOfBuff].texture = imagePath
			listOfBoostInstance[amountOfBuff].hint_tooltip = toolTip
			amountOfBuff += 1
			return listOfBoostInstance[amountOfBuff - 1]
		else:
			print ("2) Ammount of boost:",amountOfBuff)
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
#		if amountOfBuff % 5 == 0:
#			AddFillerBoxes()
		var newBoost = BoostInfoScene.instance()
		newBoost.texture = imagePath
		newBoost.hint_tooltip = toolTip
		amountOfBuff += 1
		boostBoxContainer.add_child(newBoost)
		return newBoost

# Will remove boost for player 2
func RemoveBoost(boostInstance):
	print ("remove start")
	for index in range(listOfBoostInstance.size()):
		if listOfBoostInstance[index] == boostInstance:
			print("Removing: ", listOfBoostInstance[index].hint_tooltip)
			listOfBoostInstance[index].texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/EmptySlot.png")
			listOfBoostInstance[index].hint_tooltip = ""
			for i in range (index, amountOfBuff - 1):
				
				var origChildIndex = listOfBoostInstance[i + 1].get_index()
				
				boostBoxContainer.move_child(listOfBoostInstance[i + 1], listOfBoostInstance[i].get_index())
				boostBoxContainer.move_child(listOfBoostInstance[i], origChildIndex)
				
				var temp = listOfBoostInstance[i] 
				listOfBoostInstance[i] = listOfBoostInstance[i + 1]
				listOfBoostInstance[i + 1] = temp
			
			amountOfBuff -= 1
			
			break

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
