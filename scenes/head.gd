extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -100.0

func separate_head():
	self.visible = true

func _ready() -> void:
	self.visible = false
	separate_head()


func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity += get_gravity() * 0.5 * delta

	# On input, give upward impulse
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = -400

	# Move the bird
	move_and_slide()
