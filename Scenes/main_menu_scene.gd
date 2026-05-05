extends Control

var heldDown = false
var heldTime = 0.0
var confDuration = 1.0
var pressTime = 0.0
var progressBar: TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Tutorial.grab_focus.call_deferred()

func _input(event):
	if event is InputEventKey and event.is_pressed() and heldDown == false:
		if event.keycode == KEY_SPACE:
			heldDown = true
			pressTime = Time.get_ticks_msec() / 1000.0

	if event is InputEventKey and event.is_released():
		if event.keycode == KEY_SPACE:
			heldTime = 0.0
			pressTime = 0.0
			heldDown = false
			resetProgress()
			var a = InputEventAction.new()
			a.action = "ui_focus_next"
			a.pressed = true
			Input.parse_input_event(a)


func _process(delta: float) -> void:
	if heldDown == true:
		heldTime = Time.get_ticks_msec() / 1000.0 
		var compare = heldTime - pressTime
		print_debug(compare)
		if compare >= confDuration:
			print_debug("Held Time Finished")
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
				print_debug(first_child.value)


func resetProgress():
	var currentBar = get_viewport().gui_get_focus_owner()
	if currentBar == null: pass
	else: 
		var first_child = currentBar.get_child(0)
		if first_child.is_class("TextureProgressBar"):
			first_child.value = 0.0


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")


func _on_endless_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.
