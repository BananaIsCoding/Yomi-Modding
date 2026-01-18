extends PlayerExtra

#welcome to playerextra AKA HELL

#if you need to edit hte names of the 2 buttons, you can press on them
#in the inspector on the right youll see a Text variable, which is their name in game
#and also a Icon variable, if you want your button to have some cool icon

#oh and also theres the Hint section in the inspector, that determines the text that appears when you hover over the buttons for a bit
#already wrote something in those, though you can always change it

onready var attack = $BL_ATTACK
onready var bloodfeast = $BL_BLOODFEAST
#getting the node paths for the 2 toggles. not needed but its convinient


func _ready():
	attack.connect("pressed", self, "emit_signal", ["data_changed"])
	bloodfeast.connect("pressed", self, "emit_signal", ["data_changed"])
#connecting the data to the player, this is so predictions properly update

func get_extra():
	return {
		"attack": attack.get_data(), 
		"bloodfeast": bloodfeast.get_data()
	}
	#this is what is checked by process_extra() in the fighter script

func update_selected_move(move_state): #runs everytime you press a move
	.update_selected_move(move_state)
	bloodfeast.disabled = false #i start with disabling both buttons so that the rest of the code actually works
	attack.disabled = false
	if is_instance_valid(fighter):#checks if the character is real, safety precaution
	
		if move_state is CharacterState: #checks if youre in a characterstate. fun fact Hold is considerede "Null" so this also prevents you from pressing buttons on hold, just to avoid bullshittery
			if fighter.bloodpools.size() > 0: #checks if you have any bloodpool
				attack.show()#if so, show the buttons
				bloodfeast.show()
			else:
				attack.hide() #otherwise, hide them and set them to false, as a safety precaution
				bloodfeast.hide()
				attack.set_pressed_no_signal(false)
				bloodfeast.set_pressed_no_signal(false)
			
		
		
		
		else:
			attack.hide()#if you pressed Hold, hide the buttons
			bloodfeast.hide()
			attack.set_pressed_no_signal(false)
			bloodfeast.set_pressed_no_signal(false)
	
	if attack.pressed: #if you pressed attack, you cannot press bloodfeast
		bloodfeast.pressed = false
		bloodfeast.disabled = true
	if bloodfeast.pressed: #if you pressed bloodfeast, you cannot press attack
		attack.pressed = false
		attack.disabled = true






