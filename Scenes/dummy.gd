extends Node2D

var max_health = 20
var health = 20

var hit_flash_time = 0.1
var normal_color = Color(1,1,1)
var hit_color = Color(1,0.3,0.3)

func _ready():
	add_to_group("enemies")
	$HealthBar.max_value = max_health

func take_damage(amount):
	health -= amount
	
	update_health_bar()
	flash_red()
	
	if health <= 0:
		die()

func flash_red():
	modulate = hit_color
	
	await get_tree().create_timer(hit_flash_time).timeout
	
	modulate = normal_color

func update_health_bar():
	var bar = $HealthBar
	
	if health < max_health:
		bar.visible = true
	
	bar.value = health

func die():
	print("Enemy died")
	queue_free()
