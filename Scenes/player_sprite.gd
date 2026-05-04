extends Sprite2D

func _process(_delta):
	global_rotation = $"../..".facing_angle + PI/2
