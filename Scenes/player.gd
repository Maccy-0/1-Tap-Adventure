extends Node2D

const HOLD_THRESHOLD = 0.2
const DOUBLE_TAP_TIME = 0.3

var press_time = 0.0
var last_tap_time = -1.0
var holding = false
var spin_speed = 2.0
var spin_dir = 1
var facing_direction = Vector2.UP.rotated(rotation)

var speed = 200.0
var velocity = Vector2.ZERO
var spinning = true
var backing = false
var backtimer = 0

func _input(event):
	
	if event.is_action_pressed("action"):
		press_time = Time.get_ticks_msec() / 1000.0
		holding = true

	if event.is_action_released("action"):
		var now = Time.get_ticks_msec() / 1000.0
		var held_duration = now - press_time
		holding = false

		if held_duration < HOLD_THRESHOLD:
			# Tap
			if now - last_tap_time < DOUBLE_TAP_TIME:
				print("Back")
				var direction = Vector2.RIGHT.rotated(rotation)
				velocity = -direction * speed * 0.06
				position += velocity
				rotation += PI
				backtimer = 0
				backing = true
			else:
				print("other way")
				spin_dir *= -1
			last_tap_time = now

func _process(delta: float) -> void:
	if spinning == true && backing == false:
		rotation += spin_speed * spin_dir * delta
		
		#$PlayerSprite.rotation = -rotation
		#arrow.rotation = rotation
	
	if holding: #if holding and state == SPINNING:
		if Time.get_ticks_msec() / 1000.0 - press_time > HOLD_THRESHOLD:
			print("forward")
			spinning = false
			var direction = Vector2.RIGHT.rotated(rotation)
			velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		spinning = true
			
func _physics_process(delta):
	position += velocity * delta
	
	print(backtimer)
	if backing == true:
		backtimer += delta
		if backtimer > 0.2:
			spinning = true
			backing = false
