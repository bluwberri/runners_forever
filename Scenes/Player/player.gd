extends CharacterBody2D

#Variables that are for the physics
var accel = 2000/0.2
var deaccel = 0.2
var topSpeed = 1000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state : States = States.FALLING
var jumpTime = 0.1
var jumpAllow : float
var jumpForce = 1250
var gravityMultiplier = 1
var curRunDir = 1
@export var knockbacktimer : Timer
@export var wallColider : Area2D
@export var animation : AnimatedSprite2D

enum States {IDLE, RUNNING, JUMPING, FALLING, KNOCKBACK, WALLSLIDING}


# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	if curRunDir == 1:
		wallColider.rotation_degrees = 0
		animation.flip_h = 0
	else:
		wallColider.rotation_degrees = 180
		animation.flip_h = 1
	print(gravity * gravityMultiplier)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if state not in [States.WALLSLIDING]:
			set_state(States.FALLING)
		velocity.y += (gravity * gravityMultiplier) * delta
		if state != States.WALLSLIDING: 
			jumpAllow += delta
		
	elif is_on_floor() and not state in [States.KNOCKBACK]:
		set_state(States.RUNNING)
		velocity.y = 0
		jumpAllow = 0
	
	if not Input.is_action_pressed("left") and not Input.is_action_pressed("right") and state not in [States.KNOCKBACK, States.WALLSLIDING, States.FALLING] and is_on_floor():
		set_state(States.IDLE)
		animation.animation = "idle"
		
	print(velocity.x)
	if Input.is_action_just_pressed("jump") and jumpAllow < jumpTime:
		if state in [States.IDLE,States.RUNNING,States.FALLING,States.WALLSLIDING]:
			set_state(States.JUMPING)
			velocity.y -= jumpForce
	if state not in [States.KNOCKBACK, States.WALLSLIDING]:
		if is_on_floor():
			if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				set_state(States.RUNNING)
			if Input.is_action_pressed("left") and velocity.x > -topSpeed:
				velocity.x -= accel * delta
				curRunDir = -1
			if Input.is_action_pressed("right") and velocity.x < topSpeed:
				velocity.x += accel * delta
				curRunDir = 1
			if not Input.is_action_pressed("left") and not Input.is_action_pressed("right") and velocity.x != 0:
				velocity.x = lerpf(velocity.x, 0, deaccel)
				if velocity.x == 0:
					set_state(States.IDLE)
	if state in [States.JUMPING, States.FALLING]:
		if Input.is_action_pressed("left") and velocity.x > -topSpeed:
			velocity.x -= (accel * delta) * 0.15
			curRunDir = -1
		if Input.is_action_pressed("right") and velocity.x < topSpeed:
			velocity.x += (accel * delta) * 0.15
			curRunDir = 1
	velocity.x = clampf(velocity.x,-topSpeed,topSpeed)
	move_and_slide()
	
func set_state(new_state):
	var previous_state := state
	state = new_state
	if previous_state == States.WALLSLIDING and state in [States.JUMPING, States.FALLING]:
		curRunDir *= -1
		velocity.x = topSpeed * curRunDir
		gravityMultiplier = 1
		velocity.y = -200
	if state == States.WALLSLIDING:
		animation.animation = "wallsliding"
		gravityMultiplier = 0.5
		jumpAllow = 0
		animation.stop()
		if velocity.y < -250:
			velocity.y = -250
	if previous_state == States.WALLSLIDING and state in [States.IDLE, States.RUNNING]:
		gravityMultiplier = 1
	if state in [States.RUNNING]:
		animation.animation = "running"
		animation.play()
	if state == States.JUMPING:
		animation.animation = "jumping"
		animation.play()
	if state == States.FALLING:
		animation.animation = "falling"
		animation.play()
	if state == States.KNOCKBACK:
		animation.animation = "knockback"
		animation.play()
	if state == States.IDLE:
		animation.animation = "idle"
		animation.play()
		
	
	
	

func _on_wall_colider_area_entered(area: Area2D) -> void:
	if state in [States.RUNNING]:
		velocity.x = -700 * curRunDir
		knockbacktimer.start()
		print(state)
		set_state(States.KNOCKBACK)
		print("ajgesb")
		
	if state in [States.FALLING,States.JUMPING]:
		set_state(States.WALLSLIDING)

func _on_timer_timeout() -> void:
	set_state(States.RUNNING)
