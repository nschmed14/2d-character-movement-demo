extends CharacterBody2D

@export var walk_speed = 450.0
@export var run_speed = 1050.0
@export var run_decel = 10.0
@export_range(0, 1) var deceleration = 0.1
@export_range(0, 1) var acceleration = 0.1

@export var jump_force = -700
@export_range(0,1) var decelerate_on_jump_release = 0.5


@export var dash_speed = 1500.0
@export var dash_max_distance = 300.0
@export var dash_curve : Curve
@export var dash_cooldown = 1.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()):
		velocity.y = jump_force

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release

	# Determine target speed
	var target_speed = walk_speed
	if Input.is_action_pressed("run") and is_on_floor():
		target_speed = run_speed
	
	# Get the input direction
	var direction := Input.get_axis("left", "right")
	
	# Handle horizontal movement
	if direction:
		# Moving
		if is_on_floor():
			# Ground acceleration
			velocity.x = move_toward(velocity.x, direction * target_speed, target_speed * acceleration)
		else:
			# Air acceleration
			velocity.x = move_toward(velocity.x, direction * target_speed, target_speed * 0.05)
	else:
		# Not moving - apply deceleration
		if is_on_floor():
			# Ground deceleration
			velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
		else:
			# Air deceleration
			velocity.x = move_toward(velocity.x, 0, walk_speed * 0.03)
	
	# Handle dash
	if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_position = position.x
		dash_direction = direction
		dash_timer = dash_cooldown

	if is_dashing:
		var current_distance = abs(position.x - dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0
			
	if dash_timer > 0:
		dash_timer -= delta
	
	move_and_slide()
