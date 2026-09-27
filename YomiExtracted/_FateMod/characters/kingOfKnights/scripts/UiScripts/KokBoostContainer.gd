extends PlayerInfo

export (PackedScene) var BoostInfoScene
export (int) var slotOffsetBoxes = 1 
onready var boostBoxContainer = $"%HFlowContainer"
onready var parentContainer = $"%HBoxContainer"
onready var mainBuffSlot
onready var installBuffSlot

var createdRows = 0
var amountOfBuff = 2

var listOfBoostInstance = []

func set_fighter(fighter):
	.set_fighter(fighter)
	fighter.BoostInfoUiInstance = self
		
func _ready():
	yield(get_tree(), "idle_frame") 
	
	if is_instance_valid(fighter):
		
		installBuffSlot = BoostInfoScene.instance()
		listOfBoostInstance.append(installBuffSlot)
		installBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/HiddenMode.png")
		installBuffSlot.hint_tooltip = "- Chance For Move To Be Unparriable\n- Chance For Slightly Bigger Hitbox"
		
		mainBuffSlot = BoostInfoScene.instance()
		listOfBoostInstance.append(mainBuffSlot)
		mainBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/AttackSpeedBuff.png")
		mainBuffSlot.hint_tooltip = "+1 Frame Advantage"
		
		if player_id == 2:
			createdRows = 1
			parentContainer.alignment = BoxContainer.ALIGN_END
			
			var thirdBox = BoostInfoScene.instance()
			var secondBox = BoostInfoScene.instance()
			var firstBox = BoostInfoScene.instance()
			
			listOfBoostInstance.append(thirdBox)
			listOfBoostInstance.append(secondBox)
			listOfBoostInstance.append(firstBox)
			
			boostBoxContainer.add_child(firstBox)
			boostBoxContainer.add_child(secondBox)
			boostBoxContainer.add_child(thirdBox)
			
			boostBoxContainer.add_child(mainBuffSlot)
			boostBoxContainer.add_child(installBuffSlot)
		else:
			boostBoxContainer.add_child(installBuffSlot)
			boostBoxContainer.add_child(mainBuffSlot)

func _process(delta):
	if is_instance_valid(fighter):
		pass
	
func ChangeMainBuff(armourOn : bool ):
	var currentStance = fighter.stance
	if armourOn:
		mainBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/DefenceBuff.png")
		mainBuffSlot.hint_tooltip = "+10% Damage Reduction"
	else:
		mainBuffSlot.texture = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/AttackSpeedBuff.png")
		mainBuffSlot.hint_tooltip = "+1 Frame Advantage" 

func AddBoost(imagePath, toolTip):
	if createdRows > 0:
		if amountOfBuff < listOfBoostInstance.size():
			listOfBoostInstance[amountOfBuff].texture = imagePath
			listOfBoostInstance[amountOfBuff].hint_tooltip = toolTip
			amountOfBuff += 1
			return listOfBoostInstance[amountOfBuff - 1]
		else:
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
	for index in range(listOfBoostInstance.size()):
		if listOfBoostInstance[index] == boostInstance:
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

# could do recursive if it get longer than 5 per row
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
