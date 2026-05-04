extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Tutorial.grab_focus.call_deferred()

func _input(event):
	if event is InputEventKey and event.is_released():
		if event.keycode == KEY_F:
			var a = InputEventAction.new()
			a.action = "ui_focus_next"
			a.pressed = true
			Input.parse_input_event(a)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")


func _on_endless_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.
