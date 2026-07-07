extends Panel

signal challenge_pressed()
signal replay_challenge_pressed(member)
signal avatar_loaded()



onready var owner_actions = $OwnerActions

var member



var _avatar_border: Panel
var _avatar_mouse_over: = false





var _last_self_button_status: = ""

func _ready():
	Steam.connect("avatar_loaded", self, "_loaded_Avatar")
	$"%ChallengeButton".connect("pressed", self, "on_challenge_pressed")
	$"%ReplayChallengeButton".connect("pressed", self, "on_replay_challenge_pressed")
	
	
	$"%AvatarIcon".connect("gui_input", self, "_on_avatar_gui_input")
	$"%AvatarIcon".mouse_filter = Control.MOUSE_FILTER_STOP
	$"%AvatarIcon".mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	
	
	
	
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0)
	border_style.border_width_left = 1
	border_style.border_width_top = 1
	border_style.border_width_right = 1
	border_style.border_width_bottom = 1
	border_style.border_color = Color.white
	_avatar_border = Panel.new()
	_avatar_border.name = "HoverBorder"
	_avatar_border.anchor_right = 1.0
	_avatar_border.anchor_bottom = 1.0
	_avatar_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_avatar_border.add_stylebox_override("panel", border_style)
	_avatar_border.hide()
	$"%AvatarIcon".add_child(_avatar_border)
	$"%AvatarIcon".connect("mouse_entered", self, "_on_avatar_mouse_entered")
	$"%AvatarIcon".connect("mouse_exited", self, "_on_avatar_mouse_exited")
	
	
	
	
	SteamLobby.connect("lobby_data_update", self, "_on_lobby_data_update")
	
	
	SteamLobby.connect("user_block_state_changed", self, "_on_user_block_state_changed")
	
	
	
	SteamLobby.connect("lobby_user_popup_hidden", self, "_on_lobby_user_popup_hidden")

func init(member):

	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, member.steam_id)
	$"%Username".text = member.steam_name
	_refresh_block_mute_prefix(member.steam_id)
	
	
	var custom = Global.get_remote_name_color(member.steam_id)
	if custom != null:
		$"%Username".add_color_override("font_color", custom)
	else:
		$"%Username".remove_color_override("font_color")
	self.member = member
	$"%OwnerIcon".visible = false
	$"%ChallengeButton".hide()
	$"%ReplayChallengeButton".hide()
	$"%ChallengeButton".disabled = false
	$"%ChallengeButton".text = "challenge"
	if Steam.getLobbyOwner(SteamLobby.LOBBY_ID) == member.steam_id:
		$"%OwnerIcon".visible = true
	var status = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, member.steam_id, "status")
	var status_label = _format_status_label(member.steam_id, status)
	if SteamHustle.STEAM_ID != member.steam_id:
		
		
		
		$"%ChallengeButton".show()
		if SteamLobby.LOBBY_REPLAY_CHALLENGE_ENABLED:
			$"%ReplayChallengeButton".show()
		else:
			$"%ChallengeButton".margin_right = 92
		if status != "idle":
			$"%ChallengeButton".disabled = true
			$"%ReplayChallengeButton".hide()
			$"%ChallengeButton".margin_right = 92
			$"%ChallengeButton".text = status_label
		
		
		if SteamLobby.is_blocked(member.steam_id):
			$"%ChallengeButton".disabled = true
			$"%ReplayChallengeButton".hide()
			$"%ChallengeButton".margin_right = 92
			$"%ChallengeButton".text = "blocked"
			_apply_blocked_bg($"%ChallengeButton")
		else:
			_apply_status_bg($"%ChallengeButton", "")
	else:
		
		
		
		
		$"%ChallengeButton".show()
		$"%ChallengeButton".margin_right = 92
		_refresh_self_button()




func _refresh_self_button():
	if member == null or member.steam_id != SteamHustle.STEAM_ID:
		return
	
	
	
	
	
	
	
	var steam_status = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, member.steam_id, "status")
	var display_status = steam_status
	if steam_status != "fighting" and steam_status != "spectating":
		display_status = "busy" if Global.lobby_busy_mode else "idle"
	
	
	
	
	
	if display_status == _last_self_button_status:
		return
	_last_self_button_status = display_status
	$"%ChallengeButton".text = _format_status_label(member.steam_id, display_status)
	$"%ChallengeButton".disabled = not (display_status == "idle" or display_status == "busy")
	_apply_status_bg($"%ChallengeButton", display_status)




func _apply_status_bg(btn: Button, status: String):
	if status != "idle" and status != "busy":
		btn.remove_stylebox_override("normal")
		btn.remove_stylebox_override("hover")
		btn.remove_stylebox_override("pressed")
		btn.remove_stylebox_override("disabled")
		return
	var bg = StyleBoxFlat.new()
	var hover = StyleBoxFlat.new()
	var pressed = StyleBoxFlat.new()
	match status:
		"idle":
			bg.bg_color = Color("008561")
			hover.bg_color = Color("64d26b")
			pressed.bg_color = Color("000000")
		"busy":
			bg.bg_color = Color("343537")
			hover.bg_color = Color("42525c")
			pressed.bg_color = Color("000000")
	for sb in [bg, hover, pressed]:
		sb.border_width_bottom = 1
		sb.border_width_right = 1
		sb.border_color = Color.black
	btn.add_stylebox_override("normal", bg)
	btn.add_stylebox_override("hover", hover)
	btn.add_stylebox_override("pressed", pressed)

func _apply_blocked_bg(btn: Button):
	
	
	
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("300505")
	sb.border_width_bottom = 1
	sb.border_width_right = 1
	sb.border_color = Color.black
	btn.add_stylebox_override("normal", sb)
	btn.add_stylebox_override("hover", sb)
	btn.add_stylebox_override("pressed", sb)
	btn.add_stylebox_override("disabled", sb)





const _PREFIX_NODE_NAME = "BlockMutePrefix"

func _refresh_block_mute_prefix(steam_id: int):
	var inner_hbox = $"HBoxContainer/VBoxContainer/HBoxContainer"
	
	
	
	
	
	for child in inner_hbox.get_children():
		if child.name.begins_with(_PREFIX_NODE_NAME):
			inner_hbox.remove_child(child)
			child.free()
	var text = ""
	if SteamLobby.is_blocked(steam_id):
		text = "[X] "
	elif SteamLobby.is_muted(steam_id):
		text = "[M] "
	if text == "":
		return
	var lbl = Label.new()
	lbl.name = _PREFIX_NODE_NAME
	lbl.text = text
	lbl.add_color_override("font_color", Color("85001f"))
	inner_hbox.add_child(lbl)
	
	
	inner_hbox.move_child(lbl, 1)

func _on_lobby_data_update(_a = null, _b = null, _c = null):
	
	
	
	if not is_visible_in_tree():
		return
	_refresh_self_button()

func _on_user_block_state_changed(_steam_id = null):
	
	
	
	if member != null:
		init(member)

func _format_status_label(steam_id, status) -> String:
	if status == "fighting":
		var opp = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, steam_id, "opponent_id")
		if opp != "":
			return "fighting " + Steam.getFriendPersonaName(int(opp))
		return "fighting"
	elif status == "spectating":
		var spec = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, steam_id, "spectating_id")
		if spec != "":
			return "spectating " + Steam.getFriendPersonaName(int(spec))
		return "spectating"
	return status





func update_avatar():
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, member.steam_id)

func on_challenge_pressed():
	if member == null:
		return
	
	
	if member.steam_id == SteamHustle.STEAM_ID:
		Global.lobby_busy_mode = not Global.lobby_busy_mode
		Global.save_options()
		SteamLobby.apply_busy_mode()
		_refresh_self_button()
		return
	emit_signal("challenge_pressed")
	SteamLobby.challenge_user(member)

func on_replay_challenge_pressed():
	if member:
		emit_signal("replay_challenge_pressed", member)

func _loaded_Avatar(id: int, size: int, buffer: PoolByteArray) -> void :
	if id != member.steam_id:
		return
	print("Avatar for user: " + str(id))
	print("Size: " + str(size))
	
	var AVATAR = Image.new()
	var AVATAR_TEXTURE: ImageTexture = ImageTexture.new()
	AVATAR.create_from_data(size, size, false, Image.FORMAT_RGBA8, buffer)
	
	AVATAR_TEXTURE.create_from_image(AVATAR)
	
	$"%AvatarIcon".set_texture(AVATAR_TEXTURE)
	emit_signal("avatar_loaded")

func _on_avatar_gui_input(event: InputEvent):
	if not (event is InputEventMouseButton):
		return
	if not event.pressed or event.button_index != BUTTON_LEFT:
		return
	if member == null:
		return
	
	
	if member.steam_id == SteamHustle.STEAM_ID:
		return
	_show_owner_popup()

func _on_avatar_mouse_entered():
	_avatar_mouse_over = true
	_refresh_avatar_border()

func _on_avatar_mouse_exited():
	_avatar_mouse_over = false
	_refresh_avatar_border()





func _refresh_avatar_border():
	if _avatar_border == null or member == null:
		return
	var popup_open = SteamLobby.is_lobby_user_popup_open_for(member.steam_id)
	_avatar_border.visible = _avatar_mouse_over or popup_open

func _show_owner_popup():
	var avatar_rect = $"%AvatarIcon".get_global_rect()
	var pos = avatar_rect.position + Vector2(0, avatar_rect.size.y)
	SteamLobby.show_lobby_user_popup(pos, member.steam_id)
	_refresh_avatar_border()

func _on_lobby_user_popup_hidden(_steam_id = null):
	_refresh_avatar_border()
