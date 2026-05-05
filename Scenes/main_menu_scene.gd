extends Control

var heldDown = false
var heldTime = 0.0
var confDuration = 1.0
var pressTime = 0.0
var progressBar: TextureProgressBar
var settingsMenu
#Change to global
var volumeBar: TextureProgressBar
var aPlayer: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Tutorial.grab_focus.call_deferred()
	settingsMenu = $SettingsMenu
	volumeBar = $SettingsMenu/Control/TextureProgressBar
	setVolume()
	settingsMenu.visible = false
	Global.mainMenu = 0

func _input(event):
	if Global.mainMenu == 0:
		if event is InputEventKey and event.is_pressed() and heldDown == false:
			if event.is_action_pressed("action"):
				heldDown = true
				pressTime = Time.get_ticks_msec() / 1000.0

		if event is InputEventKey and event.is_released():
			if event.is_action_released("action") && heldDown == true:
				heldTime = 0.0
				pressTime = 0.0
				heldDown = false
				resetProgress()
				var a = InputEventAction.new()
				a.action = "ui_focus_next"
				a.pressed = true
				Input.parse_input_event(a)


	if Global.mainMenu == 2:
		if event is InputEventKey and event.is_pressed() and heldDown == false:
			if event.is_action_pressed("action"):
				heldDown = true
				pressTime = Time.get_ticks_msec() / 1000.0
		if event is InputEventKey and event.is_released():
			if event.is_action_released("action") && heldDown == true:
				progressBar = $SettingsMenu/UXControl/TextureProgressBar
				heldTime = 0.0
				progressBar.value = heldTime
				pressTime = 0.0
				heldDown = false
				if Global.masterVolume < 10.0: 
					Global.masterVolume += 1.0
				else: if Global.masterVolume >= 10.0:
					Global.masterVolume = 0.0
				setVolume()


func _process(delta: float) -> void:
#Main Screen Logic
	if Global.mainMenu == 0:
		if heldDown == true:
			heldTime = Time.get_ticks_msec() / 1000.0 
			var compare = heldTime - pressTime
			if compare >= confDuration:
				heldDown = false
				var a = InputEventAction.new()
				a.action = "ui_accept"
				a.pressed = true
				Input.parse_input_event(a)
		if heldTime > 0.2:
			var currentBar = get_viewport().gui_get_focus_owner()
			if currentBar == null: pass
			else: 
				var first_child = currentBar.get_child(0)
				if first_child.is_class("TextureProgressBar"):
					var currentProgress = heldTime - pressTime
					first_child.value = currentProgress * 100

# Settings Menu Logic
	if Global.mainMenu == 2:
		if heldDown == true:
			heldTime = Time.get_ticks_msec() / 1000.0 
			var compare = heldTime - pressTime
			if compare >= confDuration:
				heldDown = false
				heldTime = 0.0
				_close_settings()

		if heldTime > 0.2:
			var currentBar = $SettingsMenu/UXControl/TextureProgressBar
			if currentBar == null: pass
			else: 
				var first_child = currentBar
				if first_child.is_class("TextureProgressBar"):
					var currentProgress = heldTime - pressTime
					first_child.value = currentProgress * 100


func resetProgress():
	heldDown = false
	var currentBar = get_viewport().gui_get_focus_owner()
	if currentBar == null: pass
	else: 
		var first_child = currentBar.get_child(0)
		if first_child.is_class("TextureProgressBar"):
			first_child.value = 0.0
			

func setVolume():
	var volumeBar = $SettingsMenu/Control/TextureProgressBar
	volumeBar.value = Global.masterVolume
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(Global.masterVolume * .1))
	print_debug(Global.masterVolume * .1)

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")


func _on_endless_pressed() -> void:
	pass


func _on_settings_pressed() -> void:
	resetProgress()
	heldTime = 0.0
	Global.mainMenu = 2
	settingsMenu.visible = true;
	progressBar = $SettingsMenu/Control/TextureProgressBar
	progressBar.value = Global.masterVolume


func _on_credits_pressed() -> void:
	pass

func _close_settings():
	settingsMenu.visible = false
	Global.mainMenu = 0
	$"VBoxContainer/Settings~".grab_focus.call_deferred()
