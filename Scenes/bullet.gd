extends Area2D

@export var speed := 200.0
var direction := Vector2.ZERO

func _ready():
	# Convert rotation into a direction vector
	direction = Vector2.RIGHT.rotated(rotation)

func _process(delta):
	position += direction * speed * delta

func get_player_root(node):
	while node != null:
		if node.is_in_group("player"):
			return node
		node = node.get_parent()
	return null

func _on_body_entered(body):
	print("I'm in")
	
	var player = get_player_root(body)
	
	if player:
		player.take_damage(9)
		queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
