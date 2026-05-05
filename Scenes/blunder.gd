extends Node2D

var max_health = 10
var health = 10

var hit_flash_time = 0.1
var normal_color = Color(1,1,1)
var hit_color = Color(1,0.3,0.3)

var enemies_in_range
var timer = 0

var player
var detection_range = 500.0
var bullet_scene = preload("res://Assets/bullet.tscn")

func _ready():
	add_to_group("enemies")
	$HealthBar.max_value = max_health
	
	player = get_tree().get_first_node_in_group("player")

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
	if player == null:
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist <= detection_range:
		enemies_in_range = player
		look_at(player.global_position)
		
		timer += delta
		if timer > 4.5:
			fire()
			timer = 0
	else:
		enemies_in_range = null
		timer = 0

func fire():
	var bullet_count = 5
	var spread_deg = 30.0
	
	var base_rotation = rotation
	var start_angle = deg_to_rad(-spread_deg / 2)
	var step = deg_to_rad(spread_deg / (bullet_count - 1))
	
	for i in range(bullet_count):
		var bullet = bullet_scene.instantiate()
		
		bullet.global_position = global_position
		
		var angle = start_angle + step * i
		bullet.rotation = base_rotation + angle
		
		get_parent().add_child(bullet)
	
	print("Spread Fire")
	$BlunderGun.play()
	
	var new_texture1 = load("res://Assets/Blunderbuss fired.png")
	$Sprite2D/Sprite2D.texture = new_texture1
	
	await get_tree().create_timer(0.1).timeout
	
	var new_texture2 = load("res://Assets/Blunderbuss.png")
	$Sprite2D/Sprite2D.texture = new_texture2

func update_health_bar():
	var bar = $HealthBar
	
	if health < max_health:
		bar.visible = true
	
	bar.value = health

func get_enemy_root(node):
	if node.is_in_group("player"):
		return node
	return null

func die():
	print("Enemy died")
	queue_free()
