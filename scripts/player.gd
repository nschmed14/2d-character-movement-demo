extends CharacterBody2D

@export var walk_speed = 450.0
@export var run_speed = 1050.0
@export_range(0, 1) var deceleration = 0.1
@export_range(0, 1) var acceleration = 0.1

@export var jump_force = -700
@export_range(0,1) var decelerate_on_jump_release = 0.5

@export var dash_speed = 2000.0
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

		
	var speed
	if Input.is_action_pressed("run") and is_on_floor():
		speed = run_speed
		print('1')
	elif velocity.x > walk_speed:
		speed = move_toward(velocity.x, walk_speed, walk_speed * deceleration)
		print('2')
	elif velocity.x < -(walk_speed):
		speed = move_toward(velocity.x, walk_speed, walk_speed * deceleration)
		print(velocity.x)
	else:
		speed = walk_speed
		print('3')
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
		
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
