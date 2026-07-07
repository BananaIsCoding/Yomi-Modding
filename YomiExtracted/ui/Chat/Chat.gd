extends Window

const MAX_LINES = 300
const PROMPT_GREEN: = Color("#33dd55")
const PROMPT_RED: = Color("#dd3333")

const TAB_MATCH = 0
const TAB_LOBBY = 1
const TAB_PLAYERS = 2
const TAB_TITLES = ["match", "lobby", "users"]

export  var force_mute_on_hide = false

var showing = false



var pending_style_request: = false






var match_scroll: ScrollContainer
var match_container: VBoxContainer

var players_scroll: ScrollContainer
var players_container: VBoxContainer
var unread_match: = false
var unread_lobby: = false
var unread_players: = false


var _was_in_match: = false



var _known_match_spectators: = {}



var _known_spectators_match_key: = ""


func _ready():

	$"%ShowButton".connect("pressed", self, "toggle")
	$"%LineEdit".connect("message_ready", self, "on_message_ready")
	Network.connect("chat_message_received", self, "on_chat_message_received")
	Network.connect("style_save_request_received", self, "_on_style_save_request_received")
	Network.connect("style_save_response_received", self, "_on_style_save_response_received")
	Network.connect("match_ready", self, "_on_match_ready")
	SteamLobby.connect("chat_message_received", self, "on_steam_chat_message_received")
	SteamLobby.connect("lobby_data_update", self, "_on_lobby_data_update")
	SteamLobby.connect("user_block_state_changed", self, "_on_user_block_state_changed")
	SteamLobby.connect("chat_history_synced", self, "_on_chat_history_synced")
	SteamLobby.connect("chat_history_loading_changed", self, "_on_chat_history_loading_changed")
	if static_:
		$"%ShowButton".hide()
	SteamLobby.connect("user_joined", self, "_on_user_joined")
	SteamLobby.connect("user_left", self, "_on_user_left")
	_setup_tabs()
	_rebuild_player_list()


func _setup_tabs():
	var lobby_scroll = $"%ScrollContainer"
	var parent = lobby_scroll.get_parent()
	
	
	match_scroll = ScrollContainer.new()
	match_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	match_scroll.rect_min_size = lobby_scroll.rect_min_size
	parent.add_child(match_scroll)
	parent.move_child(match_scroll, lobby_scroll.get_index() + 1)
	match_container = VBoxContainer.new()
	match_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	match_scroll.add_child(match_container)
	match_scroll.hide()
	
	
	players_scroll = ScrollContainer.new()
	players_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	players_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	players_scroll.rect_min_size = lobby_scroll.rect_min_size
	parent.add_child(players_scroll)
	parent.move_child(players_scroll, match_scroll.get_index() + 1)
	players_container = VBoxContainer.new()
	players_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	players_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	players_scroll.add_child(players_container)
	players_scroll.hide()
	$"%Tabs".add_tab(TAB_TITLES[TAB_MATCH])
	$"%Tabs".add_tab(TAB_TITLES[TAB_LOBBY])
	$"%Tabs".add_tab(TAB_TITLES[TAB_PLAYERS])
	
	
	
	$"%Tabs".add_color_override("font_color_bg", Color(0.35, 0.35, 0.35))
	$"%Tabs".connect("tab_changed", self, "_on_tab_changed")
	$"%TabButton".connect("toggled", self, "_on_tab_button_toggled")
	_update_tabs_visibility()
	
	
	
	_replay_chat_history()
	
	
	
	
	var player_list_timer: = Timer.new()
	player_list_timer.wait_time = 0.5
	player_list_timer.autostart = true
	player_list_timer.connect("timeout", self, "_rebuild_player_list")
	add_child(player_list_timer)
	
	
	
	
	
	for sc in [$"%ScrollContainer", match_scroll, players_scroll]:
		if sc == null:
			continue
		_apply_min_grabber_height(sc.get_v_scrollbar(), 20)
		
		
		
		
		
		
		sc.set_meta("at_bottom", true)
		sc.get_v_scrollbar().connect("value_changed", self, "_on_scroll_value_changed", [sc])

func _on_tab_button_toggled(_pressed):
	_update_tabs_visibility()

func _on_match_ready(_data):
	pending_style_request = false
	
	
	
	_rebuild_match_container_from_history()
	_update_tabs_visibility()
	if $"%Tabs".visible:
		
		
		$"%Tabs".current_tab = TAB_MATCH
		_on_tab_changed(TAB_MATCH)

var _last_known_match_key: = ""

func _on_lobby_data_update(_success = null, _lobby_id = null, _member_id = null):
	
	
	
	
	var key = SteamLobby.current_match_key()
	if key != _last_known_match_key:
		_last_known_match_key = key
		_rebuild_match_container_from_history()
	_update_tabs_visibility()
	
	
	_rebuild_player_list()

func _update_tabs_visibility():
	var status = SteamLobby.get_status()
	var in_match = status == "fighting" or status == "spectating"
	
	
	
	$"%TabButton".visible = in_match
	$"%Tabs".visible = in_match and not $"%TabButton".pressed
	
	
	
	if in_match and not _was_in_match:
		$"%Tabs".current_tab = TAB_MATCH
	_was_in_match = in_match
	if not in_match:
		
		
		
		match_scroll.hide()
		players_scroll.hide()
		$"%ScrollContainer".show()
		unread_match = false
		
		
		if $"%Tabs".current_tab != TAB_LOBBY:
			$"%Tabs".current_tab = TAB_LOBBY
		else:
			
			
			
			
			
			_scroll_lobby_to_bottom_deferred()
	else:
		_apply_active_tab()
	_refresh_tab_titles()

func _scroll_lobby_to_bottom_deferred():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if has_node("%ScrollContainer"):
		$"%ScrollContainer".scroll_vertical = 1874919424

func _on_tab_changed(idx):
	if idx == TAB_MATCH:
		unread_match = false
	elif idx == TAB_PLAYERS:
		unread_players = false
	else:
		unread_lobby = false
	_apply_active_tab()
	_refresh_tab_titles()
	
	
	
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	_active_scroll().scroll_vertical = 1874919424

func _apply_active_tab():
	var active = _active_category()
	match_scroll.visible = active == "match"
	players_scroll.visible = active == "players"
	$"%ScrollContainer".visible = active == "lobby"

func _active_scroll() -> ScrollContainer:
	var active = _active_category()
	if active == "match":
		return match_scroll
	if active == "players":
		return players_scroll
	return $"%ScrollContainer" as ScrollContainer

func _active_category() -> String:
	
	
	
	if SteamLobby.LOBBY_ID == 0:
		return "lobby"
	match $"%Tabs".current_tab:
		TAB_MATCH:
			
			
			var status = SteamLobby.get_status()
			if status == "fighting" or status == "spectating":
				return "match"
			return "lobby"
		TAB_PLAYERS:
			return "players"
		_:
			return "lobby"

func _container_for(category):
	return match_container if category == "match" else $"%MessageContainer"







const SCROLL_STICK_PX = 5

func _at_bottom(scroll: ScrollContainer) -> bool:
	if scroll == null:
		return true
	return scroll.get_meta("at_bottom", true)

func _on_scroll_value_changed(_v, scroll: ScrollContainer):
	if scroll == null:
		return
	var sb = scroll.get_v_scrollbar()
	if sb == null:
		scroll.set_meta("at_bottom", true)
		return
	
	
	if sb.max_value <= sb.page:
		scroll.set_meta("at_bottom", true)
		return
	scroll.set_meta("at_bottom", sb.value + sb.page >= sb.max_value - SCROLL_STICK_PX)

func _refresh_tab_titles():
	$"%Tabs".set_tab_title(TAB_MATCH, ("*" if unread_match else "") + TAB_TITLES[TAB_MATCH])
	$"%Tabs".set_tab_title(TAB_LOBBY, ("*" if unread_lobby else "") + TAB_TITLES[TAB_LOBBY])
	
	
	
	$"%Tabs".set_tab_title(TAB_PLAYERS, TAB_TITLES[TAB_PLAYERS])



func _categorize_message(steam_id) -> String:
	
	
	
	
	
	var sender_status: String
	if steam_id == SteamHustle.STEAM_ID:
		sender_status = SteamLobby.get_status()
	else:
		sender_status = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, steam_id, "status")
	if sender_status == "idle" or sender_status == "busy":
		return "lobby"
	
	
	
	if SteamLobby.can_get_messages_from_user(steam_id):
		return "match"
	return ""

func _on_user_joined(user):
	god_message(user + " joined.")
	_rebuild_player_list()

func _on_user_left(user):
	god_message(user + " left.")
	_rebuild_player_list()

func _on_user_block_state_changed(_steam_id):
	
	
	
	_rebuild_player_list()
	
	
	
	_rebuild_lobby_container_from_history()
	_rebuild_match_container_from_history()

func _on_chat_history_synced():
	
	
	_replay_chat_history()

func line_edit_focus():
	$"%LineEdit".grab_focus()

func is_muted():
	return $"%MuteButton".pressed or ( not is_visible_in_tree() and force_mute_on_hide)
	

func on_chat_message_received(player_id: int, message: String):
	var color = "ff333d" if player_id == 2 else "1d8df5"

	var text = ProfanityFilter.filter(("<[color=#%s]" % [color]) + Network.pid_to_username(player_id) + "[/color]> " + message)
	var node = RichTextLabel.new()
	node.bbcode_enabled = true
	node.append_bbcode(text)
	node.fit_content_height = true
	if not (player_id == Network.player_id):
		play_chat_sound()
	
	
	
	
	var category = "match" if SteamLobby.get_status() in ["fighting", "spectating"] else "lobby"
	var container = _container_for(category)
	var scroll = match_scroll if category == "match" else $"%ScrollContainer"
	var stick = _at_bottom(scroll)
	container.call_deferred("add_child", node)
	if container.get_child_count() + 1 > MAX_LINES:
		container.call_deferred("remove_child", container.get_child(0))
	if category != _active_category():
		if category == "match":
			unread_match = true
		else:
			unread_lobby = true
		_refresh_tab_titles()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if stick:
		scroll.scroll_vertical = 1874919424

func god_message(message: String):
	
	
	
	play_chat_sound()
	var node = RichTextLabel.new()
	var text = ProfanityFilter.filter(":: " + message)
	node.bbcode_enabled = true
	node.append_bbcode(text)
	node.fit_content_height = true
	var stick = _at_bottom(_active_scroll())
	_container_for(_active_category()).call_deferred("add_child", node)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if stick:
		_active_scroll().scroll_vertical = 1874919424

func play_chat_sound():
	if not is_muted():
		$"ChatSound".play()







func _color_for_steam_user(steam_id: int) -> String:
	var custom = Global.get_remote_name_color(steam_id)
	if custom != null:
		return custom.to_html(false)
	var sender_status = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, steam_id, "status")
	if sender_status == "spectating":
		return "DDDDDD" if steam_id == SteamHustle.STEAM_ID else "999999"
	var pid = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, steam_id, "player_id")
	if pid == "2":
		return "ff333d"
	return "1d8df5"





func _player_list_color(steam_id: int) -> Color:
	var status = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, steam_id, "status")
	if status == "fighting":
		var pid = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, steam_id, "player_id")
		if pid == "2":
			return Color("ff333d")
		return Color("1d8df5")
	var custom = Global.get_remote_name_color(steam_id)
	if custom != null:
		return custom
	return Color.white

func _apply_min_grabber_height(scrollbar, min_h: int):
	if scrollbar == null:
		return
	
	
	
	for slot in ["grabber", "grabber_highlight", "grabber_pressed"]:
		var src_style = scrollbar.get_stylebox(slot, "VScrollBar")
		var style = src_style.duplicate() if src_style != null else StyleBoxFlat.new()
		var pad = min_h / 2
		style.content_margin_top = pad
		style.content_margin_bottom = pad
		scrollbar.add_stylebox_override(slot, style)

func _rebuild_player_list():
	if players_container == null:
		return
	for child in players_container.get_children():
		players_container.remove_child(child)
		child.queue_free()
	if SteamLobby.LOBBY_ID == 0:
		_known_match_spectators.clear()
		_known_spectators_match_key = ""
		return
	
	
	
	
	
	
	
	var p1_id = SteamLobby.steam_id_for_match_side(1)
	var p2_id = SteamLobby.steam_id_for_match_side(2)
	var local_id = SteamHustle.STEAM_ID
	var p1_member = null
	var p2_member = null
	var local_member = null
	var rest = []
	for member in SteamLobby.LOBBY_MEMBERS:
		if not SteamLobby.can_get_messages_from_user(member.steam_id):
			continue
		if p1_member == null and member.steam_id == p1_id:
			p1_member = member
		elif p2_member == null and member.steam_id == p2_id:
			p2_member = member
		elif local_member == null and member.steam_id == local_id\
		and local_id != p1_id and local_id != p2_id:
			local_member = member
		else:
			rest.append(member)
	var ordered = []
	if p1_member != null:
		ordered.append(p1_member)
	if p2_member != null:
		ordered.append(p2_member)
	if local_member != null:
		ordered.append(local_member)
	for m in rest:
		ordered.append(m)
	for member in ordered:
		var btn = Button.new()
		var label = member.steam_name
		if SteamLobby.is_blocked(member.steam_id):
			label = "[X] " + label
		elif SteamLobby.is_muted(member.steam_id):
			label = "[M] " + label
		btn.text = label
		btn.flat = true
		btn.clip_text = true
		btn.align = Button.ALIGN_LEFT
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_color_override("font_color", _player_list_color(member.steam_id))
		btn.connect("pressed", self, "_on_player_list_button_pressed", [member.steam_id, btn])
		players_container.add_child(btn)
	
	
	_refresh_match_spectators()




func _refresh_match_spectators():
	var my_match_key = SteamLobby.current_match_key()
	if my_match_key == "":
		_known_match_spectators.clear()
		_known_spectators_match_key = ""
		return
	var new_set: = {}
	for member in SteamLobby.LOBBY_MEMBERS:
		if member.steam_id == SteamHustle.STEAM_ID:
			
			
			continue
		var status = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, member.steam_id, "status")
		if status != "spectating":
			continue
		if SteamLobby.match_key_for_user(member.steam_id) != my_match_key:
			continue
		new_set[member.steam_id] = member.steam_name
	if my_match_key != _known_spectators_match_key:
		
		
		_known_match_spectators = new_set
		_known_spectators_match_key = my_match_key
		return
	for sid in new_set:
		if not (sid in _known_match_spectators):
			
			
			
			
			_post_spectator_event("--> " + new_set[sid], "aaaaaa")
	for sid in _known_match_spectators:
		if not (sid in new_set):
			_post_spectator_event("<-- " + _known_match_spectators[sid], "777777")
	_known_match_spectators = new_set

func _post_spectator_event(text, color_hex: String = "888888"):
	if match_container == null:
		return
	var node = RichTextLabel.new()
	node.bbcode_enabled = true
	node.append_bbcode("[color=#" + color_hex + "]" + ProfanityFilter.filter(text) + "[/color]")
	node.fit_content_height = true
	match_container.call_deferred("add_child", node)
	
	
	
	if $"%Tabs".current_tab != TAB_MATCH:
		unread_match = true
	_refresh_tab_titles()

func _on_chat_meta_clicked(meta):
	
	
	var steam_id = int(str(meta))
	if steam_id == 0:
		return
	_show_user_actions_popup(steam_id, get_global_mouse_position())

func _on_chat_meta_hover_started(_meta, label):
	if is_instance_valid(label):
		label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		
		
		
		
		label.meta_underlined = true

func _on_chat_meta_hover_ended(_meta, label):
	if is_instance_valid(label):
		label.mouse_default_cursor_shape = Control.CURSOR_ARROW
		label.meta_underlined = false

func _on_player_list_button_pressed(steam_id: int, src_btn: Button):
	var pos = src_btn.get_global_rect().position + Vector2(0, src_btn.get_global_rect().size.y)
	_show_user_actions_popup(steam_id, pos)

var _user_actions_popup: PopupMenu = null
var _user_actions_target: int = 0

func _show_user_actions_popup(steam_id: int, global_pos: Vector2):
	if steam_id == SteamHustle.STEAM_ID:
		
		return
	if _user_actions_popup == null:
		_user_actions_popup = PopupMenu.new()
		_user_actions_popup.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_user_actions_popup.connect("id_pressed", self, "_on_user_actions_popup_id_pressed")
		add_child(_user_actions_popup)
	_user_actions_target = steam_id
	_user_actions_popup.clear()
	_user_actions_popup.add_item("Open Steam Profile", 0)
	
	
	if not SteamLobby.is_blocked(steam_id):
		_user_actions_popup.add_item("Unmute" if SteamLobby.is_muted(steam_id) else "Mute", 1)
	_user_actions_popup.add_item("Unblock" if SteamLobby.is_blocked(steam_id) else "Block", 2)
	_user_actions_popup.rect_global_position = global_pos
	_user_actions_popup.popup()

func _on_user_actions_popup_id_pressed(id: int):
	var steam_id = _user_actions_target
	if steam_id == 0:
		return
	match id:
		0:
			Steam.activateGameOverlayToUser("steamid", steam_id)
		1:
			SteamLobby.set_muted(steam_id, not SteamLobby.is_muted(steam_id))
		2:
			SteamLobby.set_blocked(steam_id, not SteamLobby.is_blocked(steam_id))

func _render_steam_message(steam_id: int, message: String, category: String, silent: bool):
	var color = _color_for_steam_user(steam_id)
	var steam_name = Steam.getFriendPersonaName(steam_id)
	
	
	
	var name_bbcode = "[url=%d][color=#%s]%s[/color][/url]" % [steam_id, color, steam_name]
	var text = ProfanityFilter.filter("<" + name_bbcode + "> " + message)
	var node = RichTextLabel.new()
	node.bbcode_enabled = true
	
	
	node.meta_underlined = false
	node.append_bbcode(text)
	node.fit_content_height = true
	node.connect("meta_clicked", self, "_on_chat_meta_clicked")
	
	
	
	node.connect("meta_hover_started", self, "_on_chat_meta_hover_started", [node])
	node.connect("meta_hover_ended", self, "_on_chat_meta_hover_ended", [node])
	var container = _container_for(category)
	
	
	
	
	
	
	
	
	var stick = _at_bottom(_active_scroll())
	
	
	container.add_child(node)
	
	
	if silent:
		return
	var is_active = category == _active_category()
	if is_active and steam_id != SteamHustle.STEAM_ID:
		play_chat_sound()
	if not is_active:
		if category == "match":
			unread_match = true
		else:
			unread_lobby = true
		_refresh_tab_titles()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if is_active and stick:
		_active_scroll().scroll_vertical = 1874919424

func _replay_chat_history():
	
	
	
	
	_rebuild_lobby_container_from_history()
	_rebuild_match_container_from_history()
	_last_known_match_key = SteamLobby.current_match_key()
	
	
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if has_node("%ScrollContainer"):
		$"%ScrollContainer".scroll_vertical = 1874919424
	if match_scroll:
		match_scroll.scroll_vertical = 1874919424

func _rebuild_lobby_container_from_history():
	if not has_node("%MessageContainer"):
		return
	var c = $"%MessageContainer"
	for child in c.get_children():
		c.remove_child(child)
		child.queue_free()
	for entry in SteamLobby.lobby_chat_history:
		
		
		
		if entry.steam_id != SteamHustle.STEAM_ID and SteamLobby.is_silenced(entry.steam_id):
			continue
		_render_steam_message(entry.steam_id, entry.message, "lobby", true)
	_apply_loading_indicator(c, SteamLobby.loading_lobby_chat_history)

func _rebuild_match_container_from_history():
	if match_container == null:
		return
	for child in match_container.get_children():
		match_container.remove_child(child)
		child.queue_free()
	var key = SteamLobby.current_match_key()
	if key != "" and SteamLobby.match_chat_history.has(key):
		for entry in SteamLobby.match_chat_history[key]:
			if entry.steam_id != SteamHustle.STEAM_ID and SteamLobby.is_silenced(entry.steam_id):
				continue
			_render_steam_message(entry.steam_id, entry.message, "match", true)
	_apply_loading_indicator(match_container, SteamLobby.loading_match_chat_history)




const _LOADING_NODE_NAME = "ChatLoadingIndicator"

func _apply_loading_indicator(container, loading: bool):
	if container == null:
		return
	var existing = null
	if container.has_node(_LOADING_NODE_NAME):
		existing = container.get_node(_LOADING_NODE_NAME)
	if not loading:
		if existing != null:
			container.remove_child(existing)
			existing.free()
		return
	if existing != null:
		container.move_child(existing, 0)
		return
	var lbl = Label.new()
	lbl.name = _LOADING_NODE_NAME
	lbl.text = "loading messages..."
	lbl.add_color_override("font_color", Color("888888"))
	container.add_child(lbl)
	container.move_child(lbl, 0)

func _on_chat_history_loading_changed():
	if has_node("%MessageContainer"):
		_apply_loading_indicator($"%MessageContainer", SteamLobby.loading_lobby_chat_history)
	if match_container != null:
		_apply_loading_indicator(match_container, SteamLobby.loading_match_chat_history)

func on_steam_chat_message_received(steam_id: int, message: String, scope: String = "", match_key: String = ""):
	
	
	
	if steam_id != SteamHustle.STEAM_ID and SteamLobby.is_silenced(steam_id):
		return
	
	
	
	
	
	
	var category
	if scope == "lobby":
		category = "lobby"
	elif scope == "match":
		
		
		if steam_id == SteamHustle.STEAM_ID or SteamLobby.can_get_messages_from_user(steam_id):
			category = "match"
		else:
			category = ""
	else:
		category = _categorize_message(steam_id)
	if category == "":
		return
	_render_steam_message(steam_id, message, category, false)

func unfocus_line_edit():
	$"%LineEdit".release_focus()

func on_message_ready(message):
	$"%TooLongLabel".hide()
	if Network.multiplayer_active or SteamLobby.SPECTATING:
		if len(message) < 1000:
			$"%LineEdit".clear()
			send_message(message)
		else:
			$"%TooLongLabel".show()
			$"%TooLongLabel".text = "message too long (" + str(len(message)) + "/1000)"
	else:
		send_message(message)
		$"%LineEdit".clear()

func process_command(message: String):
	if Network.multiplayer_active and not SteamLobby.SPECTATING:
		if message.begins_with("/em "):
			Network.rpc_("player_emote", [Network.player_id, message])
			return true
	else:
		if message.begins_with("/em "):
			if is_instance_valid(Global.current_game):
				var player = Global.current_game.get_player(1)
				if player:
					player.emote(message.split("/em ")[ - 1])
			return true
		if message.begins_with("/em1 "):
			if is_instance_valid(Global.current_game):
				var player = Global.current_game.get_player(1)
				if player:
					player.emote(message.split("/em1 ")[ - 1])
			return true
		if message.begins_with("/em2 "):
			if is_instance_valid(Global.current_game):
				var player = Global.current_game.get_player(2)
				if player:
					player.emote(message.split("/em2 ")[ - 1])
			return true
	
	return false

func send_message(message):
	if process_command(message):
		return

	if "[img" in message and "ui/unknown2.png" in message:
		SteamHustle.unlock_achievement("ACH_JUMPSCARE")
	if not Network.multiplayer_active and not SteamLobby.SPECTATING:
		on_chat_message_received(1, message)
		return
	if not Network.steam:
		Network.rpc_("send_chat_message", [Network.player_id, message])
	else:
		
		
		
		
		
		
		
		var scope = ""
		var cat = _active_category()
		if cat == "match":
			scope = "match"
		elif cat == "lobby" and SteamLobby.get_status() in ["fighting", "spectating"]:
			scope = "lobby"
		SteamLobby.send_chat_message(message, scope)

func _on_style_save_request_received(target_player_id, requester_id, requester_name, style_name):
	
	
	
	
	if SteamLobby.SPECTATING:
		return
	if Network.player_id != target_player_id:
		return
	if pending_style_request:
		return
	pending_style_request = true
	if not visible:
		show()
	_show_style_save_prompt(target_player_id, requester_id, requester_name, style_name)

func _show_style_save_prompt(target_player_id, requester_id, requester_name, style_name):
	var wrapper = VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content_height = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var display_name = style_name if style_name != "" else "your style"
	var safe_requester = ProfanityFilter.filter(requester_name)
	var safe_style = ProfanityFilter.filter(display_name)
	label.append_bbcode(":: " + safe_requester + " wants to save your style, \"" + safe_style + "\"")
	wrapper.add_child(label)
	var button_row = HBoxContainer.new()
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var yes_btn = Button.new()
	yes_btn.text = "yes"
	yes_btn.modulate = PROMPT_GREEN
	yes_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yes_btn.rect_min_size = Vector2(0, 18)
	yes_btn.connect("pressed", self, "_on_style_prompt_response", [button_row, target_player_id, requester_id, requester_name, true])
	button_row.add_child(yes_btn)
	var no_btn = Button.new()
	no_btn.text = "no"
	no_btn.modulate = PROMPT_RED
	no_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no_btn.rect_min_size = Vector2(0, 18)
	no_btn.connect("pressed", self, "_on_style_prompt_response", [button_row, target_player_id, requester_id, requester_name, false])
	button_row.add_child(no_btn)
	wrapper.add_child(button_row)
	_container_for(_active_category()).call_deferred("add_child", wrapper)
	play_chat_sound()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	_active_scroll().scroll_vertical = 1874919424

func _on_style_prompt_response(prompt_node, target_player_id, requester_id, requester_name, allowed):
	pending_style_request = false
	Network.broadcast_rpc("receive_style_save_response", [target_player_id, requester_id, requester_name, allowed])
	if is_instance_valid(prompt_node):
		prompt_node.queue_free()
	god_message(("granted save permission to " if allowed else "denied save permission to ") + requester_name + ".")

func _on_style_save_response_received(target_player_id, requester_id, requester_name, allowed):
	
	
	if not _response_matches_me(requester_id, requester_name):
		return
	if allowed:
		god_message("p%d granted save permission." % target_player_id)
	else:
		god_message("p%d denied save permission." % target_player_id)

func _response_matches_me(requester_id, requester_name) -> bool:
	if Network.steam:
		return requester_id != 0 and requester_id == SteamHustle.STEAM_ID
	return requester_name == Global.get_player_data().username

func toggle():
	visible = not visible








