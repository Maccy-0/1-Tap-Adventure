extends Label

func _process(delta):
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	text = "Enemies left: " + str(enemies.size())
