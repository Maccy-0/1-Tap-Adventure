extends Node2D

const HOLD_THRESHOLD = 0.2
const DOUBLE_TAP_TIME = 0.3

var press_time = 0.0
var last_tap_time = -1.0
var spin_speed = 2.0
var spin_dir = 1
var facing_direction = Vector2.UP.rotated(rotation)

var speed = 200.0
var velocity = Vector2.ZERO
var spinning = true
var backing = false
var backtimer = 0

var enemies_in_range = []

var max_health = 10
var health = 10

var attack_cooldown = 2.0
var attack_timer = 0.0

var sword
var sword_start_pos
var sword_start_rot
var facing_angle = 0.0

var inputState = 0
var trueTimer = 0
var rng = RandomNumberGenerator.new()
var wavetimer = 0
var dead = false

func _ready():
	add_to_group("player")
	sword = $RemoteTransform2D/PlayerSprite/SwordSprite
	sword_start_pos = sword.position
	sword_start_rot = sword.rotation
	inputState = 0
	dead = false
	health = 10
	$"../CanvasLayer/ProgressBar".value = health
	
	$Enter.play()
	$Music.play()

func _input(event):
	
	if event.is_action_pressed("action"):
		if inputState == 0:
			inputState = 1
		if inputState == 3:
			inputState = 5

	if event.is_action_released("action"):
		Global.holding = false
		if inputState == 1:
			inputState = 3
			trueTimer = 0
		if inputState == 2:
			inputState = 0

func _process(delta: float) -> void:
	if inputState == 0:
		rotation += spin_speed * spin_dir * delta
	if inputState == 1:
		trueTimer += delta
		if trueTimer > 0.2:
			trueTimer = 0
			inputState = 2
	if inputState == 2:
		Global.holding = true
	if inputState == 3:
		trueTimer += delta
		if trueTimer > 0.2:
			trueTimer = 0
			inputState = 4
	if inputState == 4:
		spin_dir *= -1
		inputState = 0
	if inputState == 5:
		var direction = Vector2.RIGHT.rotated(rotation)
		velocity = -direction * speed * 0.06
		position += velocity
		rotation += PI
		inputState = 2
	
	if Global.holding:
		var direction = Vector2.RIGHT.rotated(rotation)
		velocity = direction * speed
			
		facing_angle = direction.angle()
	else:
		velocity /= 1.02
		spinning = true
		
		
func _physics_process(delta):
	position += velocity * delta
	
	attack_timer -= delta
	if attack_timer <= 0:
		attack_timer = attack_cooldown
		try_attack()

func get_enemy_root(node):
	while node != null:
		if node.is_in_group("enemies"):
			return node
		node = node.get_parent()
	return null

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#print("something here")
	var enemy = get_enemy_root(body)

	if enemy:
		enemies_in_range.append(enemy)
		#print("Found enemy")


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#print("something gone")
	var enemy = get_enemy_root(body)
	if enemy:
		enemies_in_range.erase(enemy)
		#print("Lost enemy")


func get_closest_enemy():
	var closest = null
	var closest_dist = INF

	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue

		var dist = global_position.distance_to(enemy.global_position)

		if dist < closest_dist:
			closest_dist = dist
			closest = enemy
			
	return closest

func try_attack():
	var target = get_closest_enemy()
	
	if target == null:
		return
	
	perform_attack(target)

func perform_attack(target):
	animate_sword_attack()
	
	var my_random_number = rng.randf_range(-10, 10)
	if my_random_number> 0:
		$Sword1.play()
	else:
		$Sword2.play()
	
	my_random_number = rng.randf_range(-10, 10)
	if my_random_number> 0:
		$"Hit 1".play()
	else:
		$"Hit 2".play()
	
	await get_tree().create_timer(0.1).timeout
	
	if is_instance_valid(target):
		target.take_damage(10)


func animate_sword_attack():
	var tween = create_tween()
	
	# Move to center + rotate
	tween.tween_property(sword, "position", Vector2.ZERO, 0.05)
	tween.parallel().tween_property(sword, "rotation", sword_start_rot + PI, 0.05)
	
	# Return to original
	tween.tween_property(sword, "position", sword_start_pos, 0.05)
	tween.parallel().tween_property(sword, "rotation", sword_start_rot, 0.05)

func take_damage(amount):
	if dead == false: 
		health -= amount
		health = max(health, 0)
		print("Player health:", health)
		$"../CanvasLayer/ProgressBar".value = health
		$IGotHit.play()
	
		if health <= 0:
			dead = true
			die()

func heal(amount):
	health += amount
	health = min(health, max_health)
	print("Player healed:", health)
	$"../CanvasLayer/ProgressBar".value = health
	$"Keg Drink".play()
	
func die():
	print("Player died")
	$Music.stop()
	$Death.play()
	set_process(false)
	set_physics_process(false)
	
	flicker_and_reload()

func flicker_and_reload():
	for i in range(10):
		visible = false
		await get_tree().create_timer(0.1).timeout
		visible = true
		await get_tree().create_timer(0.1).timeout
		
	visible = false
	await get_tree().create_timer(6.0).timeout
	
	
	get_tree().change_scene_to_file("res://Scenes/MainMenuScene.tscn")
