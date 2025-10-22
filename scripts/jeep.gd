extends CharacterBody2D
# Top-down vehicle controller for Godot 4.x
# Sprite faces +Y (down in Godot coordinates), but pressing "Up" moves upward on screen.

@export var max_speed: float = 400.0
@export var acceleration: float = 1200.0
@export var braking_force: float = 1800.0
@export var coast_deceleration: float = 600.0
@export var reverse_speed: float = 180.0
@export var turn_speed: float = 3.5
@export var drift_factor: float = 0.85
@export var min_steer_speed: float = 20.0

func _physics_process(delta: float) -> void:
	# Input (so ui_up means move up on screen)
	var accel = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var steer_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var braking = Input.is_action_pressed("ui_select") or Input.is_action_pressed("brake")

	# Local forward direction (sprite faces +Y)
	var forward_dir = Vector2.DOWN.rotated(rotation)
	var right_dir = Vector2(forward_dir.y, -forward_dir.x)

	# Decompose built-in velocity
	var forward_vel_amount = forward_dir.dot(self.velocity)
	var right_vel_amount = right_dir.dot(self.velocity)
	var forward_vel = forward_dir * forward_vel_amount
	var lateral_vel = right_dir * right_vel_amount

	# Apply drift
	lateral_vel *= drift_factor

	# Recombine
	self.velocity = forward_vel + lateral_vel

	# Acceleration / reverse
	if accel > 0.0:
		self.velocity += forward_dir * acceleration * accel * delta
	elif accel < 0.0:
		self.velocity += forward_dir * acceleration * accel * delta

	# Braking
	if braking:
		var forward_component = forward_dir.dot(self.velocity)
		var brake_amount = clamp(abs(forward_component), 0.0, braking_force * delta)
		self.velocity -= forward_dir * sign(forward_component) * brake_amount
	else:
		if accel == 0.0:
			self.velocity = self.velocity.move_toward(Vector2.ZERO, coast_deceleration * delta)

	# Speed caps
	var current_forward = forward_dir.dot(self.velocity)
	var lateral_only = self.velocity - forward_dir * current_forward
	if current_forward > 0.0:
		self.velocity = forward_dir * min(current_forward, max_speed) + lateral_only
	else:
		self.velocity = forward_dir * max(current_forward, -reverse_speed) + lateral_only

	# Steering (reverse direction when backing up)
	var speed_for_steer = self.velocity.length()
	if speed_for_steer > min_steer_speed:
		var forward_sign = sign(forward_dir.dot(self.velocity))
		var steer_scale = clamp(speed_for_steer / max_speed, 0.0, 1.0)
		rotation += steer_input * turn_speed * steer_scale * forward_sign * delta

	# Move
	move_and_slide()
