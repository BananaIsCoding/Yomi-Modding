extends CanvasLayer

onready var p1_action_buttons = $"%P1ActionButtons"
onready var p2_action_buttons = $"%P2ActionButtons"
var _name_color_publish_timer: Timer

signal singleplayer_started()
signal multiplayer_started()
signal loaded_replay(match_data)
signal replay_picked_for_challenge(match_data, path)
signal received_synced_time()

var replay_picker_for_challenge = false




var game
var turns_taken = {
	1: false, 
	2: false
}

var turn_time = 30

var p1_turn_time = 30
var p2_turn_time = 30









var timer_mode = "default"
var chess_timer = false




var p1_debt = 0.0
var p2_debt = 0.0








var p1_just_ran_out = false
var p2_just_ran_out = false

var draw_bg_circle = false

var lock_in_tick = - INF

const DISCORD_URL = "https://discord.gg/YourOnlyMoveIsHUSTLE"
const TWITTER_URL = "https://x.com/YourMoveHUSTLE"
const IVY_SLY_URL = "https://www.ivysly.com"
const TIKTOK_URL = "https://www.tiktok.com/@youronlymoveishustle"
const STEAM_URL = "https://store.steampowered.com/app/2212330"
const ITCH_URL = "https://ivysly.itch.io/your-only-move-is-hustle"
var MIN_TURN_TIME = 5.0

onready var lobby = $Lobby
onready var direct_connect_lobby = $DirectConnectLobby
onready var p1_turn_timer = $"%P1TurnTimer"
onready var p2_turn_timer = $"%P2TurnTimer"
onready var block_advantage_label = $"%BlockAdvantageLabel"
onready var neutral_label = $"%NeutralLabel"

var p1_synced_time = null
var p2_synced_time = null

var game_started = false
var timer_sync_tick = - 1
var actionable = false

var forfeit_pressed = false

var actionable_time = 0

var received_synced_time = false

var quit_on_rematch = true

var p1_time_run_out = false
var p2_time_run_out = false

var p1_info_scene
var p2_info_scene

onready var global_option_check_buttons = {
	$"%EnableStyleColorsButton": "enable_custom_colors", 
	$"%EnableAurasButton": "enable_custom_particles", 
	$"%EnableHitsparksButton": "enable_custom_hit_sparks", 
	$"%ShowCommunityEventsButton": "show_community_events", 
	$"%EnableEmotes": "enable_emotes", 
	$"%LastMoveIndicatorButton": "show_last_move_indicators", 
	$"%ProjectileOwnersButton": "show_projectile_owners", 
	$"%PlaybackHotkeysRequireWindowButton": "playback_hotkeys_require_window", 
	$"%SpeedLinesButton": "speed_lines_enabled", 
	$"%AutoFCButton": "auto_fc", 
	$"%ExtraInfoButton": "show_extra_info", 
	$"%TimerSoundButton": "enable_timer_sound", 
	$"%ExtraFreezeFrames": "replay_extra_freeze_frames", 
	$"%EnableReplayBackups": "enable_replay_backups", 
	$"%XYPlotInvertSnapButton": "xyplot_invert_snap", 
	$"%HealthCountButton": "show_health_count", 
	$"%NextTurnHudButton": "show_next_turn_info_hud", 
	$"%ShowNextTurnOnCharsButton": "show_next_turn_info_on_chars", 

}

func _enter_tree():
	if Global.character_select_node == null:
		Global.character_select_node = $"%CharacterSelect"
	else:
		$"%CharacterSelect".free()
		var css: Node = Global.character_select_node
		add_child(css)
		move_child(css, 15)
		css.name = "CharacterSelect"
		css.owner = owner
		css.unique_name_in_owner = true
		css.reset()

func _ready():
	if Global.winws_detected:

		$"%SteamMultiplayerButton".disabled = true
		$"%WinwsLabel".show()
	if not Global.XY_SNAP_TOGGLE_ENABLED:
		
		
		
		
		$"%XYPlotInvertSnapButton".hide()
	
	$"%SingleplayerButton".connect("pressed", self, "_on_singleplayer_pressed")
	$"%MultiplayerButton".connect("pressed", self, "_on_multiplayer_pressed")
	$"%SteamMultiplayerButton".connect("pressed", self, "_on_steam_multiplayer_pressed")
	$"%CustomizeButton".connect("pressed", self, "_on_customize_pressed")
	$"%DirectConnectButton".connect("pressed", self, "_on_direct_connect_button_pressed")
	$"%RematchButton".connect("pressed", self, "_on_rematch_button_pressed")
	$"%QuitButton".connect("pressed", self, "_on_quit_button_pressed")
	$"%QuitToMainMenuButton".connect("pressed", self, "_on_quit_button_pressed")
	$"%ForfeitButton".connect("pressed", self, "_on_forfeit_button_pressed")
	$"%QuitProgramButton".connect("pressed", self, "_on_quit_program_button_pressed")
	$"%ResumeButton".connect("pressed", self, "pause")
	$"%ReplayButton".connect("pressed", self, "_on_view_replays_button_pressed")
	$"%ReplayCancelButton".connect("pressed", self, "_on_replay_cancel_pressed")
	$"%OpenReplayFolderButton".connect("pressed", self, "open_replay_folder")
	$"%P1ActionButtons".connect("turn_ended", self, "end_turn_for", [1])
	$"%P2ActionButtons".connect("turn_ended", self, "end_turn_for", [2])
	$"%ShowAutosavedReplays".connect("pressed", self, "_on_view_replays_button_pressed")
	$"%ShowBackupReplays".connect("pressed", self, "_on_view_replays_button_pressed")
	if has_node("%ReplaySearchEdit"):
		$"%ReplaySearchEdit".connect("text_changed", self, "_on_replay_search_changed")
	if has_node("%VersionModeButton"):
		$"%VersionModeButton".connect("pressed", self, "_on_version_mode_pressed")
	_refresh_version_mode_label()
	if has_node("%NoMissingCharactersToggle"):
		$"%NoMissingCharactersToggle".connect("toggled", self, "_on_replay_filter_toggle_changed")
	
	
	
	
	if has_node("%MissingConfirmButton"):
		$"%MissingConfirmButton".connect("pressed", self, "_on_missing_char_confirmed")
	if has_node("%MissingCancelButton"):
		$"%MissingCancelButton".connect("pressed", self, "_on_missing_char_cancelled")
	if has_node("%OldVersionConfirmButton"):
		$"%OldVersionConfirmButton".connect("pressed", self, "_on_old_version_confirmed")
	if has_node("%OldVersionCancelButton"):
		$"%OldVersionCancelButton".connect("pressed", self, "_on_old_version_cancelled")
	$"%DiscordButton".connect("pressed", Steam, "activateGameOverlayToWebPage", [DISCORD_URL])
	$"%IvySlyLinkButton".connect("pressed", Steam, "activateGameOverlayToWebPage", [IVY_SLY_URL])
	$"%WishlistButton".connect("pressed", Steam, "activateGameOverlayToWebPage", [STEAM_URL])
	$"%TwitterButton".connect("pressed", Steam, "activateGameOverlayToWebPage", [TWITTER_URL])
	$"%TikTokButton".connect("pressed", Steam, "activateGameOverlayToWebPage", [TIKTOK_URL])
	$"%ItchButton".connect("pressed", Steam, "activateGameOverlayToWebPage", [ITCH_URL])
	$"%ResetZoomButton".connect("pressed", self, "_on_reset_zoom_pressed")
	Network.connect("player_turns_synced", self, "on_player_actionable")
	Network.connect("player_turn_ready", self, "_on_player_turn_ready")
	Network.connect("turn_ready", self, "_on_turn_ready")
	Network.connect("sync_timer_request", self, "_on_sync_timer_request")
	Network.connect("check_players_ready", self, "check_players_ready")
	Network.connect("force_open_action_buttons", self, "on_player_actionable")
	
	if should_open_mod_warning_window():
		
		
		
		
		Global.mods_disabled_by_version_transition = false
		$"%ModWarningWindow".start()

	SteamLobby.connect("join_lobby_success", self, "_on_join_lobby_success")
	$"%OptionsContainer".hide()
	update_help_text()
	Hotkeys.connect("binding_changed", self, "_on_hotkey_changed")
	p1_turn_timer.connect("timeout", self, "_on_turn_timer_timeout", [1])
	p2_turn_timer.connect("timeout", self, "_on_turn_timer_timeout", [2])
	for lobby in [$"%Lobby", $"%DirectConnectLobby", SteamLobby]:
		lobby.connect("quit_on_rematch", $"%RematchButton", "hide")
		lobby.connect("quit_on_rematch", self, "set", ["quit_on_rematch", true])
	$"%HelpButton".connect("pressed", self, "toggle_help_screen")
	$"%OptionsBackButton".connect("pressed", $"%OptionsContainer", "hide")
	$"%OptionsButton".connect("pressed", $"%OptionsContainer", "show")
	$"%CreditsButton".connect("pressed", $"%Credits", "show")
	$"%CreditsButton".connect("pressed", $"%MainMenu", "hide")
	$"%PauseOptionsButton".connect("pressed", $"%OptionsContainer", "show")
	$"%MusicButton".set_pressed_no_signal(Global.music_enabled)
	$"%MusicButton".connect("toggled", self, "_on_music_button_toggled")
	$"%MasterSlider".set_value(Global.master_value)
	AudioServer.set_bus_volume_db(0, linear2db(Global.master_value))
	$"%MasterSlider".connect("value_changed", self, "_on_master_slider_changed")
	$"%FXSlider".set_value(Global.fx_value)
	AudioServer.set_bus_volume_db(1, linear2db(Global.fx_value))
	$"%FXSlider".connect("value_changed", self, "_on_fx_slider_changed")
	$"%UISlider".set_value(Global.ui_value)
	AudioServer.set_bus_volume_db(2, linear2db(Global.ui_value))
	$"%UISlider".connect("value_changed", self, "_on_ui_slider_changed")
	$"%MusicSlider".set_value(Global.music_value)
	AudioServer.set_bus_volume_db(3, linear2db(Global.music_value))
	$"%MusicSlider".connect("value_changed", self, "_on_music_slider_changed")
	
	
	
	$"%CustomName".text = Global.custom_name
	$"%CustomName".connect("text_changed", self, "_on_custom_name_changed")
	$"%CustomNameReset".connect("pressed", self, "_on_custom_name_reset_pressed")
	$"%NameHueSlider".set_block_signals(true)
	$"%NameHueSlider".set_value(Global.name_hue)
	$"%NameHueSlider".set_block_signals(false)
	$"%NameHueSlider".connect("value_changed", self, "_on_name_hue_changed")
	$"%NameSaturationSlider".set_block_signals(true)
	$"%NameSaturationSlider".set_value(Global.name_saturation)
	$"%NameSaturationSlider".set_block_signals(false)
	$"%NameSaturationSlider".connect("value_changed", self, "_on_name_saturation_changed")
	$"%NameColorReset".connect("pressed", self, "_on_name_color_reset_pressed")
	
	
	
	
	_name_color_publish_timer = Timer.new()
	_name_color_publish_timer.wait_time = 0.25
	_name_color_publish_timer.one_shot = true
	_name_color_publish_timer.connect("timeout", self, "_on_name_color_publish_due")
	add_child(_name_color_publish_timer)
	_refresh_name_color_preview()


	$"%FullscreenButton".set_pressed_no_signal(Global.fullscreen)
	$"%FullscreenButton".connect("toggled", self, "_on_fullscreen_button_toggled")
	$"%HitboxesButton".set_pressed_no_signal(Global.show_hitboxes)
	$"%HitboxesButton".connect("toggled", self, "_on_hitboxes_button_toggled")
	$"%CapFramerateButton".set_pressed_no_signal(Global.cap_framerate)
	$"%CapFramerateButton".connect("toggled", self, "_on_cap_framerate_button_toggled")
	$"%VsyncButton".set_pressed_no_signal(Global.vsync)
	$"%VsyncButton".connect("toggled", self, "_on_vsync_button_toggled")
	$"%PlaybackControls".set_pressed_no_signal(Global.show_playback_controls)
	$"%PlaybackControls".connect("toggled", self, "_on_playback_controls_button_toggled")
	$"%PredictionSettingsOpenButton".connect("pressed", self, "_on_open_prediction_settings_pressed")
	$"%PredictionSettingsCloseButton".connect("pressed", self, "_on_close_prediction_settings_pressed")



	if not SteamHustle.STARTED:
		pass









	else:
		$"%WishlistButton".hide()
		$"%RoadmapContainer".show()

	
	$NetworkSyncTimer.connect("timeout", self, "_on_network_timer_timeout")
	quit_on_rematch = false
	for node in global_option_check_buttons:
		node.set_pressed_no_signal(Global.get(global_option_check_buttons[node]))
		node.connect("toggled", self, "_on_global_option_toggled", [global_option_check_buttons[node]])
	
	$"%HelpScreen".hide()
	if SteamLobby.LOBBY_ID != 0:
		yield(get_tree(), "idle_frame")

		_on_join_lobby_success()
	$"%CharacterSelect".connect("opened", self, "reset_ui")

	yield(get_tree(), "idle_frame")
	
func should_open_mod_warning_window():
	
	
	
	
	return Global.mods_disabled_by_version_transition

func _on_global_option_toggled(toggled, param):
	Global.save_option(toggled, param)








func on_workshop_uploader_clicked():
	hide_main_menu()
	$"%WorkshopMenu".init()
	$"%WorkshopMenu".show()

	
func _on_music_button_toggled(on):
	Global.set_music_enabled(on)
	Global.save_options()

func _on_master_slider_changed(value):
	AudioServer.set_bus_volume_db(0, linear2db(value))
	$"%OptionsSoundPlayer".bus = "Master"
	$"%OptionsSoundPlayer".stream = load("res://sound/ui/button_hover3.wav")
	$"%OptionsSoundPlayer".play()
	Global.master_value = value
	Global.save_options()

func _on_fx_slider_changed(value):
	AudioServer.set_bus_volume_db(1, linear2db(value))
	$"%OptionsSoundPlayer".bus = "Fx"
	$"%OptionsSoundPlayer".stream = load("res://sound/common/explosion2.wav")
	$"%OptionsSoundPlayer".play()
	Global.fx_value = value
	Global.save_options()

func _on_ui_slider_changed(value):
	AudioServer.set_bus_volume_db(2, linear2db(value))
	$"%OptionsSoundPlayer".bus = "UI"
	$"%OptionsSoundPlayer".stream = load("res://sound/ui/button_hover3.wav")
	$"%OptionsSoundPlayer".play()
	Global.ui_value = value
	Global.save_options()

func _on_music_slider_changed(value):
	AudioServer.set_bus_volume_db(3, linear2db(value))
	$"%OptionsSoundPlayer".bus = "UI"
	$"%OptionsSoundPlayer".stream = load("res://sound/ui/button_hover3.wav")
	$"%OptionsSoundPlayer".play()
	Global.music_value = value
	Global.save_options()

func _on_custom_name_changed(text):
	Global.custom_name = text
	
	
	
	if text != "":
		Network.player_name = text
	Global.save_options()

func _on_custom_name_reset_pressed():
	$"%CustomName".text = ""
	Global.custom_name = ""
	Global.save_options()

func _on_name_hue_changed(value):
	Global.name_hue = value
	Global.name_color_customized = true
	_refresh_name_color_preview()
	if _name_color_publish_timer:
		_name_color_publish_timer.start()

func _on_name_saturation_changed(value):
	Global.name_saturation = value
	Global.name_color_customized = true
	_refresh_name_color_preview()
	if _name_color_publish_timer:
		_name_color_publish_timer.start()

func _on_name_color_publish_due():
	Global.save_options()
	Global.publish_name_color()

func _on_name_color_reset_pressed():
	
	
	
	
	$"%NameHueSlider".set_block_signals(true)
	$"%NameHueSlider".set_value(0.0)
	$"%NameHueSlider".set_block_signals(false)
	$"%NameSaturationSlider".set_block_signals(true)
	$"%NameSaturationSlider".set_value(0.5)
	$"%NameSaturationSlider".set_block_signals(false)
	Global.name_hue = 0.0
	Global.name_saturation = 0.5
	Global.name_color_customized = false
	Global.save_options()
	Global.publish_name_color()
	_refresh_name_color_preview()

func _refresh_name_color_preview():
	
	
	
	var name_text = "preview"
	if SteamHustle.STARTED and SteamHustle.STEAM_ID:
		var steam_name = Steam.getFriendPersonaName(SteamHustle.STEAM_ID)
		if steam_name is String and steam_name != "":
			name_text = steam_name
	$"%NameColorPreview".text = name_text
	if Global.has_name_color():
		$"%NameColorPreview".add_color_override("font_color", Global.get_name_color())
	else:
		$"%NameColorPreview".remove_color_override("font_color")

func _on_fullscreen_button_toggled(on):
	Global.set_fullscreen(on)

func _on_hitboxes_button_toggled(on):
	Global.set_hitboxes(on)

func _on_cap_framerate_button_toggled(on):
	Global.set_cap_framerate(on)

func _on_vsync_button_toggled(on):
	Global.set_vsync(on)

func _on_playback_controls_button_toggled(on):
	Global.set_playback_controls(on)

func _on_open_prediction_settings_pressed():
	$"%PredictionSettingsOpenButton".hide()
	$"%OptionsBar".show()

func _on_close_prediction_settings_pressed():
	$"%PredictionSettingsOpenButton".show()
	$"%OptionsBar".hide()

func toggle_help_screen():
	$"%HelpScreen".visible = not $"%HelpScreen".visible

func _on_join_lobby_success():
	if is_instance_valid(Global.current_game):
		return
	$"%HudLayer".hide()
	$"%SteamLobbyList".hide()
	$"%SteamLobby".show()
	$"%GameUI".hide()
	hide_main_menu(true)


func hide_main_menu(all = false):
	if all:
		$"%MainMenu".hide()
	else:
		$"%ButtonContainer".hide()
		$"%Title".hide()
		$"%RoadmapContainer".hide()

func _on_view_replays_button_pressed():
	load_replays()
	hide_main_menu()

func _on_forfeit_button_pressed():
	if is_instance_valid(game) and not game.game_finished:
		var player_id = Network.player_id
		game.get_player(player_id).on_action_selected("Forfeit", null, null)
		Network.forfeit()
		forfeit_pressed = true
		actionable = false
	$"%PausePanel".hide()

func _on_opponent_disconnected():
	if is_instance_valid(game) and not game.game_finished:
		game.get_player((game.my_id % 2) + 1).on_action_selected("Forfeit", null, null)
		Network.forfeit(true)
		print("opponent disconnected")
		forfeit_pressed = true
		actionable = false
	$"%PausePanel".hide()

func _on_customize_pressed():
	$"%MainMenu".hide()
	$"%CustomizationScreen".init()
	$"%CustomizationScreen".show()
	pass

func load_replays():
	$"%ReplayWindow".show()
	for child in $"%ReplayContainer".get_children():
		child.free()
	var replay_map = ReplayManager.load_replays($"%ShowAutosavedReplays".pressed, $"%ShowBackupReplays".pressed)
	var buttons = []
	for key in replay_map:
		var button = preload("res://ui/ReplayWindow/ReplayButton.tscn").instance()
		add_child(button)
		button.setup(replay_map, key)
		button.connect("pressed", self, "_on_replay_button_pressed", [button])
		buttons.append(button)
		remove_child(button)
	buttons.sort_custom(self, "sort_replays")
	for button in buttons:
		$"%ReplayContainer".add_child(button)
	
	
	
	_apply_replay_filter()
	for i in range(len(buttons)):
		if not is_instance_valid(self):
			break
		if not $"%ReplayWindow".visible:
			break
		if not is_instance_valid(buttons[i]):
			break
		var button = buttons[i]
		button.show_data()
		if i % 10 == 0:
			yield(button, "data_updated")
			_apply_replay_filter()

func _on_reset_zoom_pressed():
	if is_instance_valid(game):
		game.reset_zoom()

func _set_prediction_speed(speed: int):
	var btn = get_node_or_null("%%%dSpeed" % speed)
	if btn:
		btn.emit_signal("pressed")

func set_turn_time(time, minutes = false):

	p1_turn_time = time * (60 if minutes else 1)
	p2_turn_time = time * (60 if minutes else 1)
	turn_time = time * (60 if minutes else 1)
	p1_turn_timer.wait_time = p1_turn_time
	p2_turn_timer.wait_time = p2_turn_time

func sort_replays(a, b):
	return a.modified > b.modified

func _on_replay_search_changed(_text):
	_apply_replay_filter()

func _on_replay_filter_toggle_changed(_pressed):
	_apply_replay_filter()

func _apply_replay_filter():
	if not has_node("%ReplayContainer"):
		return
	var query = $"%ReplaySearchEdit".text if has_node("%ReplaySearchEdit") else ""
	query = query.strip_edges()
	
	
	
	var rx = null
	if query != "":
		var candidate = RegEx.new()
		if candidate.compile(query) == OK:
			rx = candidate
	var same_version_only = Global.replay_version_mode == "same"
	var no_missing = has_node("%NoMissingCharactersToggle") and $"%NoMissingCharactersToggle".pressed
	for child in $"%ReplayContainer".get_children():
		var name_text = ""
		var matchup_text = ""
		var btn = child.get_node_or_null("%Button")
		if btn:
			name_text = btn.text
		var matchup = child.get_node_or_null("%MatchupLabel")
		if matchup:
			matchup_text = matchup.text
		var visible_now = _replay_matches_query(name_text, matchup_text, query, rx)
		
		
		
		if visible_now and same_version_only and child.get("version") != null and child.version != "":
			if child.version != Global.VERSION:
				visible_now = false
		if visible_now and no_missing and child.get("has_missing_character"):
			visible_now = false
		child.visible = visible_now
	_refresh_replay_button_colors()

func _replay_matches_query(name_text: String, matchup_text: String, query: String, rx) -> bool:
	if query == "":
		return true
	var haystack = name_text + "\n" + matchup_text
	if haystack.findn(query) != - 1:
		return true
	if rx != null and rx.search(haystack) != null:
		return true
	return false

var _pending_missing_char_replay = null
var _pending_old_version_replay = null

const VERSION_MODE_COLORS = {
	"all": Color(1, 1, 1, 1), 
	"warn": Color(1, 0.85, 0.2, 1), 
	"same": Color(1, 0.4, 0.4, 1), 
}

func _on_replay_button_pressed(replay_button):
	if not is_instance_valid(replay_button):
		return
	
	
	
	
	
	if replay_button.has_missing_character:
		_pending_missing_char_replay = replay_button.path
		if has_node("%MissingCharConfirmDialog"):
			$"%MissingCharConfirmDialog".show()
		return
	if Global.replay_version_mode == "warn" and replay_button.version != ""\
	and replay_button.version != Global.VERSION:
		_pending_old_version_replay = replay_button.path
		if has_node("%OldVersionConfirmDialog"):
			$"%OldVersionConfirmDialog".show()
		return
	_load_replay_from_button(replay_button.path)

func _on_missing_char_confirmed():
	var path = _pending_missing_char_replay
	_pending_missing_char_replay = null
	if has_node("%MissingCharConfirmDialog"):
		$"%MissingCharConfirmDialog".hide()
	if path != null:
		_load_replay_from_button(path)

func _on_missing_char_cancelled():
	_pending_missing_char_replay = null
	if has_node("%MissingCharConfirmDialog"):
		$"%MissingCharConfirmDialog".hide()

func _on_old_version_confirmed():
	var path = _pending_old_version_replay
	_pending_old_version_replay = null
	if has_node("%OldVersionConfirmDialog"):
		$"%OldVersionConfirmDialog".hide()
	if path != null:
		_load_replay_from_button(path)

func _on_old_version_cancelled():
	_pending_old_version_replay = null
	if has_node("%OldVersionConfirmDialog"):
		$"%OldVersionConfirmDialog".hide()

func _on_version_mode_pressed():
	
	var i = Global.REPLAY_VERSION_MODES.find(Global.replay_version_mode)
	i = posmod(i + 1, Global.REPLAY_VERSION_MODES.size())
	Global.replay_version_mode = Global.REPLAY_VERSION_MODES[i]
	Global.save_options()
	_refresh_version_mode_label()
	
	
	
	_refresh_replay_button_colors()
	_apply_replay_filter()

func _refresh_version_mode_label():
	if not has_node("%VersionModeLabel"):
		return
	var mode = Global.replay_version_mode
	var label = $"%VersionModeLabel"
	label.text = mode
	var col = VERSION_MODE_COLORS.get(mode, Color.white)
	label.add_color_override("font_color", col)

func _refresh_replay_button_colors():
	if not has_node("%ReplayContainer"):
		return
	for child in $"%ReplayContainer".get_children():
		
		
		
		if child.has_missing_character:
			
			
			child.modulate = Color(1, 0.45, 0.45)
		elif child.version != "" and child.version != Global.VERSION:
			
			
			
			
			child.modulate = VERSION_MODE_COLORS["warn"]
		else:
			child.modulate = Color(1, 1, 1, 1)

func _load_replay_from_button(path):
	var match_data = ReplayManager.load_replay(path)
	$"%ReplayWindow".hide()
	if replay_picker_for_challenge:
		replay_picker_for_challenge = false
		$"%ReplayChallengeTitle".hide()
		$"%SteamLobby".show()
		emit_signal("replay_picked_for_challenge", match_data, path)
		return
	emit_signal("loaded_replay", match_data)

func _on_replay_cancel_pressed():
	if replay_picker_for_challenge:
		replay_picker_for_challenge = false
		$"%ReplayWindow".hide()
		$"%ReplayChallengeTitle".hide()
		$"%SteamLobby".show()
		return
	Global.reload()

func open_replay_picker_for_challenge(opponent_name = ""):
	replay_picker_for_challenge = true
	if opponent_name == "":
		$"%ReplayChallengeTitle".text = "Select a replay to resume with"
	else:
		$"%ReplayChallengeTitle".text = "Select a replay to resume with " + opponent_name
	$"%ReplayChallengeTitle".show()
	$"%SteamLobby".hide()
	load_replays()












func will_forfeit():
	return not SteamLobby.SPECTATING and Network.multiplayer_active and is_instance_valid(game) and not game.game_finished and not game.forfeit and not ReplayManager.playback and not forfeit_pressed

func can_quit():
	return true


func reset_ui():
	$"%HudLayer".hide()
	p1_turn_timer.stop()
	p2_turn_timer.stop()
	$"%P1TurnTimerBar".hide()
	$"%P1TurnTimerLabel".hide()
	$"%P2TurnTimerBar".hide()
	$"%P2TurnTimerLabel".hide()
	$"%GameUI".hide()
	$"%ChatWindow".hide()
	$"%PostGameButtons".hide()
	$"%OpponentDisconnectedLabel".hide()
	forfeit_pressed = false
	actionable = false

func _on_quit_button_pressed():
	if will_forfeit():
		_on_forfeit_button_pressed()
	else:
		if can_quit():
			if not Network.steam:
				Network.stop_multiplayer()
				Global.reload()
			else:
				SteamLobby.exit_match_from_button()

func _on_quit_program_button_pressed():
	get_tree().quit()

func _on_sync_timer_request(id, time):
	if not chess_timer:
		return
	
	
	
	
	
	
	if id == 1:
		p1_turn_timer.start(time)
		p1_turn_timer.paused = true
		
		
		
		
		if has_node("%P1TurnTimerLabel"):
			$"%P1TurnTimerLabel".text = time_convert(int(floor(time)))
		received_synced_time = true
		emit_signal("received_synced_time")
	elif id == 2:
		p2_turn_timer.start(time)
		p2_turn_timer.paused = true
		if has_node("%P2TurnTimerLabel"):
			$"%P2TurnTimerLabel".text = time_convert(int(floor(time)))
		received_synced_time = true
		emit_signal("received_synced_time")

func get_chess_timer_state():
	if not chess_timer:
		return null
	return {
		"p1_time_left": p1_turn_timer.time_left, 
		"p2_time_left": p2_turn_timer.time_left, 
		"turn_time": turn_time, 
		"p1_debt": p1_debt, 
		"p2_debt": p2_debt, 
		"p1_just_ran_out": p1_just_ran_out, 
		"p2_just_ran_out": p2_just_ran_out, 
	}

func restore_chess_timer_state(state):
	if not state or not chess_timer:
		return
	
	
	
	
	if state.has("p1_time_left"):
		p1_turn_timer.start(state.p1_time_left)
		p1_turn_timer.paused = true
	if state.has("p2_time_left"):
		p2_turn_timer.start(state.p2_time_left)
		p2_turn_timer.paused = true
	
	p1_debt = float(state.get("p1_debt", 0))
	p2_debt = float(state.get("p2_debt", 0))
	p1_just_ran_out = bool(state.get("p1_just_ran_out", false))
	p2_just_ran_out = bool(state.get("p2_just_ran_out", false))
	
	
	
	
	
	
	
	game_started = true
	
	
	if is_instance_valid(game) and game.match_data:
		if timer_mode == "chess":
			MIN_TURN_TIME = game.match_data.get("turn_min_length", MIN_TURN_TIME)
		elif timer_mode == "increment":
			MIN_TURN_TIME = game.match_data.get("increment_per_turn", 0)

func sync_timer(player_id):
	if Network.multiplayer_active:
		if player_id == Network.player_id:
			print("syncing timer")
			var timer = p1_turn_timer
			if player_id == 2:
				timer = p2_turn_timer
			Network.sync_timer(player_id, timer.time_left)


func id_to_action_buttons(player_id):
	if player_id == 1:
		return $"%P1ActionButtons"
	else:
		return $"%P2ActionButtons"

func init(game):
	forfeit_pressed = false
	if not ReplayManager.playback:
		$PostGameButtons.hide()
		$"%RematchButton".disabled = false
	self.game = game
	setup_action_buttons()
	if Network.multiplayer_active or SteamLobby.SPECTATING:
		game.connect("playback_requested", self, "_on_game_playback_requested")
		$"%ChatWindow".show()
	game_started = false
	timer_mode = game.match_data.get("timer_mode", "default")
	
	
	var show_timer = (Network.multiplayer_active or SteamLobby.SPECTATING) and timer_mode != "none"
	$"%P1TurnTimerLabel".visible = show_timer
	$"%P2TurnTimerLabel".visible = show_timer
	
	
	
	chess_timer = timer_mode == "chess" or timer_mode == "increment"
	p1_debt = 0.0
	p2_debt = 0.0
	p1_just_ran_out = false
	p2_just_ran_out = false
	
	
	
	ReplayManager.chess_timer_state = null
	timer_sync_tick = - 1
	lock_in_tick = - INF
	p1_time_run_out = false
	p2_time_run_out = false

func _on_player_turn_ready(player_id):
	if not is_instance_valid(game):
		return
	lock_in_tick = game.current_tick
	if player_id != Network.player_id or SteamLobby.SPECTATING:
		$"%TurnReadySound".play()

	turns_taken[player_id] = true
	if player_id == 1:
		$"%P1TurnTimerBar".hide()

		p1_turn_timer.paused = true

	elif player_id == 2:
		$"%P2TurnTimerBar".hide()

		p2_turn_timer.paused = true
	
func _on_rematch_button_pressed():
	Network.request_rematch()
	$"%RematchButton".disabled = true

func _on_game_playback_requested():
	if Network.multiplayer_active and not ReplayManager.resimulating:
		$PostGameButtons.show()
		
		
		
		
		
		
		
		if not quit_on_rematch and not SteamLobby.SPECTATING and not (is_instance_valid(game) and game.spectating):
			$"%RematchButton".show()
		else:
			$"%RematchButton".hide()
		Network.rematch_menu = true

func on_game_started():
	lobby.hide()
	$"%SteamLobby".hide()
	$MainMenu.hide()

func _on_singleplayer_pressed():
	Global.frame_advance = false
	SteamLobby.leave_Lobby()
	emit_signal("singleplayer_started")

func _on_direct_connect_button_pressed():
	direct_connect_lobby.show()
	hide_main_menu()

func _on_multiplayer_pressed():
	SteamLobby.leave_Lobby()
	lobby.show()
	hide_main_menu()
	
func _on_steam_multiplayer_pressed():
	$"%SteamLobbyList".show()
	hide_main_menu()
	

func _on_turn_ready():
	$"%P1TurnTimerBar".hide()
	$"%P2TurnTimerBar".hide()
	actionable = false


	
	var turns_taken = {
		1: false, 
		2: false
	}


func open_replay_folder():
	var folder = ProjectSettings.globalize_path("user://replay")
	OS.shell_open(folder)

func end_turn_for(player_id):
	$"%TurnReadySound".play()
	turns_taken[player_id] = true
	if player_id == Network.player_id:
		sync_timer(player_id)
	if player_id == 1:
		$"%P1TurnTimerBar".hide()

		p1_turn_timer.paused = true

	elif player_id == 2:
		$"%P2TurnTimerBar".hide()

		p2_turn_timer.paused = true
	if Network.rematch_menu:
		hide_rematch_menu()

func setup_action_buttons():
	$"%P1ActionButtons".init(game, 1)
	$"%P2ActionButtons".init(game, 2)
	
func check_players_ready():
	if is_instance_valid(game):
		if game.is_waiting_on_player():
			if lock_in_tick != game.current_tick:
				on_player_actionable()

func _on_network_timer_timeout():
	if Network.multiplayer_active:
		if not Network.turn_synced:
			if is_instance_valid(game):
				if game.player_actionable and lock_in_tick != game.current_tick and not actionable:
					Network.rpc_("check_players_ready")

func on_player_actionable():
	if actionable and (Network.multiplayer_active and not Network.undo and not Network.auto):
		return
	while is_instance_valid(game) and not game.game_paused:
		yield(get_tree(), "idle_frame")
	Network.undo = false
	Network.auto = false
	actionable = true
	actionable_time = 0





	if Network.multiplayer_active or SteamLobby.SPECTATING:

		var wait_start = OS.get_ticks_msec()
		while not (Network.can_open_action_buttons):
			if OS.get_ticks_msec() - wait_start > 3000 and not SteamLobby.SPECTATING:
				print("button-open watchdog: stuck waiting >3s, resending end_turn_simulation")
				if is_instance_valid(game):
					Network.rpc_("end_turn_simulation", [game.current_tick, Network.player_id])
				wait_start = OS.get_ticks_msec()
			yield(get_tree(), "physics_frame")

		print("starting turn timer")

		if timer_mode == "none":
			
			pass
		elif not game_started:

			if is_instance_valid(game):
				
				
				
				
				
				if timer_mode == "chess":
					MIN_TURN_TIME = game.match_data.turn_min_length
				elif timer_mode == "increment":
					MIN_TURN_TIME = game.match_data.get("increment_per_turn", 0)
			p1_turn_timer.start()
			p2_turn_timer.start()
			game_started = true
		else:
			if timer_mode == "default":
				p1_turn_timer.start(turn_time)
				p2_turn_timer.start(turn_time)
			elif timer_mode == "increment":
				_apply_increment(1)
				_apply_increment(2)
				
				
				
				
				p1_time_run_out = false
				p2_time_run_out = false
			else:
				if p1_turn_timer.time_left < MIN_TURN_TIME:
					p1_turn_timer.start(MIN_TURN_TIME)
				if p2_turn_timer.time_left < MIN_TURN_TIME:
					p2_turn_timer.start(MIN_TURN_TIME)


		if timer_mode != "none":
			p1_turn_timer.paused = false
			p2_turn_timer.paused = false






		
		
		
		
		$"%P1TurnTimerBar".show()
		$"%P2TurnTimerBar".show()



	$"%P1ActionButtons".activate()
	$"%P2ActionButtons".activate()
	if is_instance_valid(game):
		game.is_in_replay = false
	$"%AdvantageLabel".text = ""




func _on_turn_timer_timeout(player_id):
		
		
		
		
		if timer_mode == "increment":
			var inc = float(game.match_data.get("increment_per_turn", 0))
			if player_id == 1:
				p1_debt += inc
				p1_just_ran_out = true
				p1_turn_timer.start(inc)
				if Network.player_id == player_id:
					$"%P1ActionButtons".timeout()
			else:
				p2_debt += inc
				p2_just_ran_out = true
				p2_turn_timer.start(inc)
				if Network.player_id == player_id:
					$"%P2ActionButtons".timeout()
			return
		if player_id == 1:
			if Network.player_id == player_id:
				$"%P1ActionButtons".timeout()
				p1_turn_timer.wait_time = MIN_TURN_TIME
				p1_turn_timer.start()
				p1_turn_timer.paused = true
		else:
			if Network.player_id == player_id:
				$"%P2ActionButtons".timeout()
				p2_turn_timer.wait_time = MIN_TURN_TIME
				p2_turn_timer.start()
				p2_turn_timer.paused = true














func _apply_increment(player_id):
	if not is_instance_valid(game) or not game.match_data:
		return
	var inc = float(game.match_data.get("increment_per_turn", 0))
	var timer = p1_turn_timer if player_id == 1 else p2_turn_timer
	var bank = timer.time_left
	if player_id == 1:
		if not p1_just_ran_out and p1_debt > 0:
			var paid = min(bank, p1_debt)
			p1_debt -= paid
			bank -= paid
		p1_just_ran_out = false
	else:
		if not p2_just_ran_out and p2_debt > 0:
			var paid = min(bank, p2_debt)
			p2_debt -= paid
			bank -= paid
		p2_just_ran_out = false
	var debt = p1_debt if player_id == 1 else p2_debt
	if debt > 0:
		bank = inc
	else:
		bank = bank + inc
	
	
	var max_minutes = float(game.match_data.get("increment_max_time", 0))
	if max_minutes > 0:
		var max_sec = max_minutes * 60.0
		if bank > max_sec:
			bank = max_sec
	timer.start(bank)
func pause():
	$"%PausePanel".visible = not $"%PausePanel".visible
	if $"%PausePanel".visible:
		if will_forfeit():
			$"%QuitToMainMenuButton".hide()
			$"%ForfeitButton".show()
		else:
			$"%QuitToMainMenuButton".show()
			$"%ForfeitButton".hide()
		$"%SaveReplayButton".disabled = false
		$"%SaveReplayButton".text = "save replay"
		$"%SaveReplayLabel".text = ""

func _on_hotkey_changed(_action):
	update_help_text()

func update_help_text():
	$"%TopInfo".text = _format_help([
		[Hotkeys.LOCK_IN, "Lock in"], 
		[Hotkeys.WATCH_REPLAY, "Watch replay"], 
		[Hotkeys.PAUSE, "Open menu"], 
		[Hotkeys.TOGGLE_HUD, "Toggle HUD"], 
	])
	$"%TopInfoMP".text = _format_help([
		[Hotkeys.LOCK_IN, "Lock in"], 
		[Hotkeys.PAUSE, "Open menu"], 
		[Hotkeys.OPEN_CHAT, "Chat"], 
		[Hotkeys.TOGGLE_HUD, "Toggle HUD"], 
	])
	$"%TopInfoReplay".text = _format_help([
		[Hotkeys.WATCH_REPLAY, "Watch replay"], 
		[Hotkeys.EDIT_REPLAY, "Edit replay"], 
		[Hotkeys.PAUSE, "Open menu"], 
		[Hotkeys.TOGGLE_HUD, "Toggle HUD"], 
	])

func _format_help(entries: Array) -> String:
	var parts = []
	for entry in entries:
		var key_name = Hotkeys.get_display_name(entry[0])
		if key_name == "":
			continue
		parts.append("%s: %s" % [key_name, entry[1]])
	return PoolStringArray(parts).join(" - ")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		if $"%OptionsContainer".visible:
			$"%OptionsContainer".hide()
			get_tree().set_input_as_handled()
			return
	if event.is_action_pressed(Hotkeys.OPEN_CHAT):
		if is_instance_valid(game):
			$"%ChatWindow".show()
			$"%ChatWindow".line_edit_focus()
	if event.is_action_pressed(Hotkeys.TOGGLE_HUD):
		visible = not visible
		$"../HudLayer/HudLayer".visible = not $"../HudLayer/HudLayer".visible
		$"../GhostLayer".visible = visible
		Global.ui_hidden = not visible
	if event.is_action_pressed(Hotkeys.TOGGLE_FREE_CANCEL):
		_toggle_free_cancel()
	if event.is_action_pressed(Hotkeys.TOGGLE_FLIP):
		_toggle_flip()
	if event.is_action_pressed(Hotkeys.TOGGLE_PREDICTION):
		_toggle_prediction()
	if event.is_action_pressed(Hotkeys.TOGGLE_HITBOXES):
		_toggle_hitboxes()
	if event.is_action_pressed(Hotkeys.CLEAR_PARTICLES):
		_on_ClearParticlesButton_pressed()
	if event.is_action_pressed(Hotkeys.TOGGLE_PLAYBACK_CONTROLS):
		_toggle_playback_controls()
	
	
	
	
	if not Global.playback_hotkeys_require_window and not $"%ReplayControls".visible:
		if event.is_action_pressed(Hotkeys.TOGGLE_FRAME_ADVANCE):
			$"%ReplayControls".toggle_frame_advance()
		if event.is_action_pressed(Hotkeys.FRAME_ADVANCE):
			$"%ReplayControls".frame_advance_step()
	if event.is_action_pressed(Hotkeys.TOGGLE_PROJECTILE_OWNERS):
		_toggle_projectile_owners()
	if event.is_action_pressed(Hotkeys.TOGGLE_FULLSCREEN):
		_toggle_fullscreen()
	if event.is_action_pressed(Hotkeys.PLAYBACK_SPEED_1):
		_set_playback_speed(4)
	if event.is_action_pressed(Hotkeys.PLAYBACK_SPEED_2):
		_set_playback_speed(2)
	if event.is_action_pressed(Hotkeys.PLAYBACK_SPEED_3):
		_set_playback_speed( - 1)
	if event.is_action_pressed(Hotkeys.PLAYBACK_SPEED_4):
		_set_playback_speed(1)
	if event.is_action_pressed(Hotkeys.RESET_ZOOM):
		_on_reset_zoom_pressed()
	if event.is_action_pressed(Hotkeys.ZOOM_IN):
		if is_instance_valid(game):
			game.zoom_in()
	if event.is_action_pressed(Hotkeys.ZOOM_OUT):
		if is_instance_valid(game):
			game.zoom_out()
	if event.is_action_pressed(Hotkeys.FREEZE_ON_READY):
		_toggle_freeze_on_ready()
	if event.is_action_pressed(Hotkeys.TOGGLE_AFTERIMAGES):
		_toggle_afterimage()
	if event.is_action_pressed(Hotkeys.TOGGLE_FREEZE_SOUND):
		_toggle_global_button("%FreezeSound")
	if event.is_action_pressed(Hotkeys.TOGGLE_EXTRA_INFO):
		_toggle_global_button("%ExtraInfoButton")
	if event.is_action_pressed(Hotkeys.UNDO):
		_trigger_undo()
	if event.is_action_pressed(Hotkeys.PREDICTION_SPEED_1):
		_set_prediction_speed(1)
	if event.is_action_pressed(Hotkeys.PREDICTION_SPEED_HALF):
		_set_prediction_speed(5)
	if event.is_action_pressed(Hotkeys.PREDICTION_SPEED_2):
		_set_prediction_speed(2)
	if event.is_action_pressed(Hotkeys.PREDICTION_SPEED_3):
		_set_prediction_speed(3)
	_handle_xy_nudge(event)









	if event is InputEventMouseButton:
		if event.pressed:
			$"%ChatWindow".unfocus_line_edit()

func time_convert(time_in_sec):
	var seconds = time_in_sec % 60
	var minutes = (time_in_sec / 60) % 60
	var hours = (time_in_sec / 60) / 60

	
	if hours >= 1:
		return "%02d:%02d:%02d" % [hours, minutes, seconds]
	return "%02d:%02d" % [minutes, seconds]

func hide_rematch_menu():
	Network.rematch_menu = false
	var post_game_buttons = get_node_or_null("%PostGameButtons")
	var disconnected_label = get_node_or_null("%OpponentDisconnectedLabel")
	if post_game_buttons:
		post_game_buttons.hide()
	if disconnected_label:
		disconnected_label.hide()

func _process(delta):
	
	
	
	
	
	
	
	if timer_mode != "none" and ReplayManager.playback and not ReplayManager.resimulating:
		p1_turn_timer.paused = true
		p2_turn_timer.paused = true

	if chess_timer and is_instance_valid(game) and game.match_data:
		var state = {
			"p1_time_left": p1_turn_timer.time_left, 
			"p2_time_left": p2_turn_timer.time_left, 
			"turn_time": turn_time, 
			"p1_debt": p1_debt, 
			"p2_debt": p2_debt, 
			"p1_just_ran_out": p1_just_ran_out, 
			"p2_just_ran_out": p2_just_ran_out, 
		}
		game.match_data["chess_timer_state"] = state
		
		
		
		
		ReplayManager.chess_timer_state = state

	
	
	
	
	
	
	var p1_old_text = $"%P1TurnTimerLabel".text
	if not (timer_mode == "increment" and p1_turn_timer.is_paused()):
		$"%P1TurnTimerLabel".text = time_convert(int(floor(p1_turn_timer.time_left)))
	var p1_different_text = p1_old_text != $"%P1TurnTimerLabel".text

	var p2_old_text = $"%P2TurnTimerLabel".text
	if not (timer_mode == "increment" and p2_turn_timer.is_paused()):
		$"%P2TurnTimerLabel".text = time_convert(int(floor(p2_turn_timer.time_left)))
	var p2_different_text = p2_old_text != $"%P2TurnTimerLabel".text

	
	
	
	var p1_debt_label = $"%P1TurnDebtLabel"
	var p2_debt_label = $"%P2TurnDebtLabel"
	if timer_mode == "increment" and $"%P1TurnTimerLabel".visible:
		p1_debt_label.visible = p1_debt > 0
		if p1_debt > 0:
			p1_debt_label.text = "-" + time_convert(int(ceil(p1_debt)))
		p2_debt_label.visible = p2_debt > 0
		if p2_debt > 0:
			p2_debt_label.text = "-" + time_convert(int(ceil(p2_debt)))
	else:
		p1_debt_label.visible = false
		p2_debt_label.visible = false

	if $"%VersionLabel".visible:
		$"%VersionLabel".text = "version " + Global.VERSION

	if Network.undo and Network.rematch_menu:
		hide_rematch_menu()

	var you_id = 1
	var opponent_id = 2
	if Network.multiplayer_active:
		you_id = Network.player_id
		opponent_id = (you_id % 2) + 1

	if is_instance_valid(game):
		
		
		
		
		if timer_mode == "none":
			$"%P1TurnTimerBar".value = 1.0
			$"%P2TurnTimerBar".value = 1.0
		elif not p1_turn_timer.is_paused():
	
				var bar = $"%P1TurnTimerBar"
				
				
				
				
				var denom = p1_turn_timer.wait_time if timer_mode == "increment" else turn_time
				bar.value = p1_turn_timer.time_left / denom if denom > 0 else 1.0
				if p1_turn_timer.time_left < MIN_TURN_TIME:
					bar.visible = Utils.wave( - 1, 1, 0.064) > 0
					if p1_different_text and you_id == 1 and p1_turn_timer.time_left:
						if Global.enable_timer_sound and (round(p1_turn_timer.time_left) == MIN_TURN_TIME):
							if not chess_timer or not p1_time_run_out:
								p1_time_run_out = true
								$"%P1OuttaTimeSound".play()
		if timer_mode != "none" and not p2_turn_timer.is_paused():
	
				var bar = $"%P2TurnTimerBar"
				var denom = p2_turn_timer.wait_time if timer_mode == "increment" else turn_time
				bar.value = p2_turn_timer.time_left / denom if denom > 0 else 1.0
				if p2_turn_timer.time_left < MIN_TURN_TIME:
					bar.visible = Utils.wave( - 1, 1, 0.064) > 0
					if p2_different_text and you_id == 2:
						if Global.enable_timer_sound and (round(p2_turn_timer.time_left) == MIN_TURN_TIME):
							if not chess_timer or not p2_time_run_out:
								p2_time_run_out = true
								$"%P2OuttaTimeSound".play()





	if Input.is_action_just_pressed("pause"):
		pause()

	var advantage_label = $"%AdvantageLabel"

	var ghost_game = get_parent().ghost_game
	if is_instance_valid(game):
		if game.game_paused:
			if is_instance_valid(ghost_game):
				var you = ghost_game.get_player(you_id)
				var opponent = ghost_game.get_player(opponent_id)
				
				var advantage = 0
				var block_advantage = 0
				
				block_advantage = - you.blocked_hitbox_plus_frames + opponent.blocked_hitbox_plus_frames

				if you.ghost_ready_tick != null and opponent.ghost_ready_tick != null:
					advantage = opponent.ghost_ready_tick - you.ghost_ready_tick

				if advantage >= 0:
					advantage_label.set("custom_colors/font_color", Color("1d8df5"))
					advantage_label.text = "frame advantage: +" + str(advantage)
				else:
					advantage_label.set("custom_colors/font_color", Color("ff333d"))
					advantage_label.text = "frame advantage: " + str(advantage)
				if advantage == 0:
					advantage_label.text = ""

				if block_advantage > 0:
					block_advantage_label.set("custom_colors/font_color", Color("94e4ff"))
					block_advantage_label.text = "block advantage: +" + str(block_advantage)
					
				elif block_advantage < 0:
					block_advantage_label.set("custom_colors/font_color", Color("ff7a81"))
					block_advantage_label.text = "block advantage: " + str(block_advantage)
				else:
					block_advantage_label.text = ""
					pass

		else:
			advantage_label.text = ""
			block_advantage_label.text = ""
	
		if not ReplayManager.playback:
			var p1 = game.get_player(1)
			var p2 = game.get_player(2)
			var combo = p1.combo_count > 0 or p2.combo_count > 0
			var trade = p1.combo_count > 0 and p2.combo_count > 0
			var initiative = not combo and p1.state_interruptable and p2.state_interruptable and not p1.busy_interrupt and not p2.busy_interrupt
			neutral_label.text = (("<-COMBO" if game.get_player(1).combo_count > 0 else " COMBO->") if combo else ("BUSY" if not initiative else "NEUTRAL")) if not trade else "TRADE"
			neutral_label.rect_position.x = 0 if combo else 1
			neutral_label.set("custom_colors/font_color", ((Color("1d8df5") if p1.combo_count > 0 else Color("ff333d")) if combo else Color.darkgray) if not trade else Color("c735d4"))
			neutral_label.modulate.a = 1.0 if combo else 0.5 if not initiative else 1.0
		else:
			neutral_label.text = ""
	$"%P1SuperContainer".rect_min_size.y = 50 if not p1_action_buttons.visible else 0
	$"%P2SuperContainer".rect_min_size.y = 50 if not p2_action_buttons.visible else 0
	$"%TopInfo".visible = is_instance_valid(game) and not ReplayManager.playback and game.is_waiting_on_player() and not Network.multiplayer_active and not game.game_finished and not Network.rematch_menu
	$"%TopInfoMP".visible = is_instance_valid(game) and not ReplayManager.playback and game.is_waiting_on_player() and Network.multiplayer_active and not game.game_finished and not Network.rematch_menu
	$"%TopInfoReplay".visible = is_instance_valid(game) and ReplayManager.playback and not game.game_finished and not Network.rematch_menu
	$"%HelpButton".visible = is_instance_valid(game) and game.game_paused
	$"%ResetZoomButton".visible = is_instance_valid(game) and game.camera_zoom != 1.0 and game.game_paused
	if is_instance_valid(game) and not Network.multiplayer_active:
		$"%ReplayControls".show()
	else:
		$"%ReplayControls".hide()


	$"%SoftlockResetButton".visible = false
	if Network.multiplayer_active and is_instance_valid(game):
		var my_action_buttons = p1_action_buttons if Network.player_id == 1 else p2_action_buttons
		$"%SoftlockResetButton".visible = ( not my_action_buttons.visible or my_action_buttons.get_node("%SelectButton").disabled) and actionable_time > 5 and not (game.game_finished or ReplayManager.playback) and not SteamLobby.SPECTATING
		if not $"%SoftlockResetButton".visible:
			$"%SoftlockResetButton".disabled = false

		if not my_action_buttons.visible or my_action_buttons.get_node("%SelectButton").disabled:
			actionable_time += delta
		else:
			actionable_time = 0

func set_lobby_settings(settings):
	$"%CharacterSelect".lobby_match_settings = settings
	pass

func start_timers():
	yield(get_tree().create_timer(0.25), "timeout")
	if actionable:
		p1_turn_timer.paused = false
		p2_turn_timer.paused = false

func _on_SoftlockResetButton_pressed():
	Network.rpc_("send_chat_message", [Network.player_id, "-- wants to resync."])
	Network.request_softlock_fix()
	$"%SoftlockResetButton".disabled = true
	pass



func _on_ClearParticlesButton_pressed():
	if is_instance_valid(game):
		for particle in game.effects:
			if not is_instance_valid(particle):
				continue
			
			
			
			
			
			var has_trail = false
			for child in particle.get_children():
				if child is CustomTrailParticle:
					has_trail = true
					break
			if has_trail:
				particle.queue_free()
			else:
				particle.hide()
		for player_id in [1, 2]:
			for p in game.get_player(player_id).aura_particles:
				if not is_instance_valid(p):
					continue
				p.restart()
				
				
				
				if p.get("active_burst_clones") != null:
					for clone in p.active_burst_clones:
						if is_instance_valid(clone):
							clone.queue_free()
					p.active_burst_clones.clear()
	pass


func _on_RoadmapButton_toggled(button_pressed):
	$"%RoadmapListContainer".visible = button_pressed
	pass




func _toggle_free_cancel():
	if not is_instance_valid(game):
		return
	var targets = []
	if Network.multiplayer_active:
		targets.append(p1_action_buttons if Network.player_id == 1 else p2_action_buttons)
	else:
		targets = [p1_action_buttons, p2_action_buttons]
	for ab in targets:
		var feint_btn = ab.get_node("%FeintButton")
		if not feint_btn.disabled:
			feint_btn.pressed = not feint_btn.pressed
			ab.send_ui_action()

func _toggle_flip():
	if not is_instance_valid(game):
		return
	var targets = []
	if Network.multiplayer_active:
		targets.append(p1_action_buttons if Network.player_id == 1 else p2_action_buttons)
	else:
		targets = [p1_action_buttons, p2_action_buttons]
	for ab in targets:
		var reverse_btn = ab.get_node("%ReverseButton")
		if not reverse_btn.disabled:
			reverse_btn.pressed = not reverse_btn.pressed
			ab.send_ui_action()

func _toggle_prediction():
	var btn = get_node_or_null("%GhostButton")
	if btn:
		btn.set_pressed( not btn.pressed)

func _toggle_hitboxes():
	Global.show_hitboxes = not Global.show_hitboxes
	$"%HitboxesButton".set_pressed_no_signal(Global.show_hitboxes)
	Global.save_options()

func _toggle_playback_controls():
	Global.show_playback_controls = not Global.show_playback_controls
	$"%PlaybackControls".set_pressed_no_signal(Global.show_playback_controls)
	Global.save_options()
	if is_instance_valid(game) and not Network.multiplayer_active:
		$"%ReplayControls".visible = Global.show_playback_controls

func _toggle_projectile_owners():
	Global.show_projectile_owners = not Global.show_projectile_owners
	$"%ProjectileOwnersButton".set_pressed_no_signal(Global.show_projectile_owners)
	Global.save_options()

func _toggle_fullscreen():
	Global.set_fullscreen( not Global.fullscreen)
	$"%FullscreenButton".set_pressed_no_signal(Global.fullscreen)





func _toggle_global_button(node_path: String):
	var btn = get_node_or_null(node_path)
	if btn:
		btn.pressed = not btn.pressed




func _toggle_freeze_on_ready():
	var btn = get_node_or_null("%FreezeOnMyTurn")
	if btn == null:
		return
	btn.pressed = not btn.pressed
	btn.emit_signal("pressed")





func _toggle_afterimage():
	var btn = get_node_or_null("%AfterimageButton")
	if btn == null:
		return
	btn.pressed = not btn.pressed
	btn.emit_signal("pressed")

func _trigger_undo():
	if not is_instance_valid(game):
		return
	if p1_action_buttons.try_undo():
		return
	p2_action_buttons.try_undo()



func _set_playback_speed(mod):
	var slider_value = {4: 0, 2: 1, - 1: 2, 1: 3}.get(mod, 3)
	var slider = get_node_or_null("%PlaybackSpeed")
	if slider:
		slider.value = slider_value
	else:
		Global.playback_speed_mod = mod




func _handle_xy_nudge(event):
	if not is_instance_valid(Hotkeys.hovered_xy_plot):
		return
	var nudge = null
	
	
	if event.is_action_pressed(Hotkeys.NUDGE_LEFT, true):
		nudge = Vector2( - 0.01, 0)
	elif event.is_action_pressed(Hotkeys.NUDGE_RIGHT, true):
		nudge = Vector2(0.01, 0)
	elif event.is_action_pressed(Hotkeys.NUDGE_UP, true):
		nudge = Vector2(0, - 0.01)
	elif event.is_action_pressed(Hotkeys.NUDGE_DOWN, true):
		nudge = Vector2(0, 0.01)
	if nudge == null:
		return
	var plot = Hotkeys.hovered_xy_plot
	var current = plot.value_float
	var raw_new = (current + nudge * plot.panel_radius).limit_length(plot.panel_radius)
	var new_value = raw_new
	if plot.snap and not Global.XY_SNAP_TOGGLE_ENABLED:
		
		
		
		
		new_value = _xy_sticky_snap(plot, current, raw_new)
	plot.update_value(new_value, true, true)
	plot.emit_signal("data_changed")





const _XY_SNAP_AMOUNT = 0.1
const _XY_ZONE_EXIT_EPSILON = 0.001



const _XY_MOTION_EPSILON = 0.0001

func _xy_sticky_snap(plot, current: Vector2, raw_new: Vector2) -> Vector2:
	var raw_radius = raw_new.length()
	if raw_radius < 0.001:
		return Vector2.ZERO
	var final_angle = raw_new.angle()
	if plot.snap_angles > 0:
		var step = TAU / plot.snap_angles
		var offset = 0.0
		if plot.snap_align_to_limit_center and plot.limit_angle:
			offset = plot.get_limit_center()
		var current_radius = current.length()
		var current_in_zone = false
		var current_snap = 0.0
		var current_angle = 0.0
		if current_radius > 0.001:
			current_angle = current.angle()
			current_snap = offset + round((current_angle - offset) / step) * step
			current_in_zone = abs(Utils.angle_diff(current_angle, current_snap)) < _XY_SNAP_AMOUNT
		if current_in_zone:
			
			
			
			
			var angular_motion = Utils.angle_diff(current_angle, final_angle)
			if abs(angular_motion) < _XY_MOTION_EPSILON:
				
				final_angle = current_snap
			else:
				
				
				var dir = 1.0 if angular_motion > 0 else - 1.0
				final_angle = current_snap + dir * (_XY_SNAP_AMOUNT + _XY_ZONE_EXIT_EPSILON)
		else:
			var raw_snap = offset + round((final_angle - offset) / step) * step
			if abs(Utils.angle_diff(final_angle, raw_snap)) < _XY_SNAP_AMOUNT:
				
				final_angle = raw_snap
	var final_radius = raw_radius
	if plot.snap_radius > 0.0:
		var current_radius_r = current.length()
		var target_r = plot.snap_radius * plot.panel_radius
		var zone_width = _XY_SNAP_AMOUNT * plot.panel_radius
		var current_in_r_zone = abs(current_radius_r - target_r) < zone_width
		if current_in_r_zone:
			var radial_motion = raw_radius - current_radius_r
			if abs(radial_motion) < _XY_MOTION_EPSILON * plot.panel_radius:
				final_radius = target_r
			else:
				var dir = 1.0 if radial_motion > 0 else - 1.0
				final_radius = target_r + dir * (zone_width + _XY_ZONE_EXIT_EPSILON * plot.panel_radius)
		elif abs(raw_radius - target_r) < zone_width:
			final_radius = target_r
	final_radius = clamp(final_radius, 0.0, plot.panel_radius)
	return Vector2(cos(final_angle), sin(final_angle)) * final_radius


func _on_WorkshopUploader_pressed():
	on_workshop_uploader_clicked()
	pass
