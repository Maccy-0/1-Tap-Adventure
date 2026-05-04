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

var attack_cooldown = 2.0
var attack_timer = 0.0

var sword
var sword_start_pos
var sword_start_rot
var facing_angle = 0.0

func _ready():
	sword = $RemoteTransform2D/PlayerSprite/SwordSprite
	sword_start_pos = sword.position
	sword_start_rot = sword.rotation

func _input(event):
	
	if event.is_action_pressed("action"):
		press_time = Time.get_ticks_msec() / 1000.0
		Global.holding = true

	if event.is_action_released("action"):
		var now = Time.get_ticks_msec() / 1000.0
		var held_duration = now - press_time
		Global.holding = false

		if held_duration < HOLD_THRESHOLD:
			# Tap
			if now - last_tap_time < DOUBLE_TAP_TIME:
				#print("Back")
				var direction = Vector2.RIGHT.rotated(rotation)
				velocity = -direction * speed * 0.06
				position += velocity
				rotation += PI
				backtimer = 0
				backing = true
			else:
				#print("other way")
				spin_dir *= -1
			last_tap_time = now

func _process(delta: float) -> void:
	#print(enemies_in_range)
	
	if spinning == true && backing == false:
		rotation += spin_speed * spin_dir * delta
		
		#$PlayerSprite.rotation = -rotation
		#arrow.rotation = rotation
	
	if Global.holding: #if holding and state == SPINNING:
		if Time.get_ticks_msec() / 1000.0 - press_time > HOLD_THRESHOLD:
			#print("forward")
			spinning = false
			var direction = Vector2.RIGHT.rotated(rotation)
			velocity = direction * speed
			
			facing_angle = direction.angle()
	else:
		velocity = Vector2.ZERO
		spinning = true
			
func _physics_process(delta):
	#get_closest_enemy()
	
	position += velocity * delta
	
	#print(backtimer)
	if backing == true:
		backtimer += delta
		if backtimer > 0.2:
			spinning = true
			backing = false
	
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
	print("something here")
	var enemy = get_enemy_root(body)

	if enemy:
		enemies_in_range.append(enemy)
		print("Found enemy")


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("something gone")
	var enemy = get_enemy_root(body)
	if enemy:
		enemies_in_range.erase(enemy)
		print("Lost enemy")


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
