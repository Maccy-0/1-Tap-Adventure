extends Node2D

var max_health = 10
var health = 10

var hit_flash_time = 0.1
var normal_color = Color(1,1,1)
var hit_color = Color(1,0.3,0.3)

var enemies_in_range
var timer = 0

func _ready():
	add_to_group("enemies")
	$HealthBar.max_value = max_health

func take_damage(amount):
	health -= amount
	
	update_health_bar()
	flash_red()
	
	if health <= 0:
		die()

func _process(delta: float) -> void:
	if enemies_in_range != null:
		pass
		look_at(enemies_in_range.global_position)

func flash_red():
	modulate = hit_color
	
	await get_tree().create_timer(hit_flash_time).timeout
	
	modulate = normal_color

func _physics_process(delta):
	#print(enemies_in_range)
	if enemies_in_range != null:
		timer += delta
		if timer > 3:
			if enemies_in_range != null:
				#var bullet = $"../Bullet".instantiate()
				#bullet.global_position = global_position
				#bullet.rotation = rotation
				#get_tree().current_scene.add_child(bullet)
				print("Fire")
				timer = 0
			else:
				timer = 0

func update_health_bar():
	var bar = $HealthBar
	
	if health < max_health:
		bar.visible = true
	
	bar.value = health

func get_enemy_root(node):
	while node != null:
		print("Gasp")
		#if node.is_in_group("player"):
		#	return node
		#node = node.get_parent()
		return get_tree().get_first_node_in_group("player")
	return null

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("something here")
	var enemy = get_enemy_root(body)

	if enemy:
		enemies_in_range = enemy
		print("Found enemy")


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("something gone")
	var enemy = get_enemy_root(body)
	
	if enemy:
		enemies_in_range = enemy
		print("Lost enemy")

func die():
	print("Enemy died")
	queue_free()
