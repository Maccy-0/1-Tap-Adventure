extends Area2D

@export var speed := 400.0
var direction := Vector2.ZERO

func _ready():
	# Convert rotation into a direction vector
	direction = Vector2.RIGHT.rotated(rotation)

func _process(delta):
	position += direction * speed * delta
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
	
		if player:
			player.take_damage(1)
		queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
