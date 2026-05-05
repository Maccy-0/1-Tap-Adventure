extends Label

func _ready() -> void:
	$Label.visible = false

func _process(delta):
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	text = "Enemies left: " + str(enemies.size())
	
	if enemies.size() <= 0:
		$Label.visible = true
		await get_tree().create_timer(6.0).timeout
		get_tree().change_scene_to_file("res://Scenes/MainMenuScene.tscn")
