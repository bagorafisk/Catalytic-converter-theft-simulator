extends CharacterBody3D

@export var speed: float = 7.0
@export var sprint_speed: float = 12.0
@export var jump_strength: float = 4.5
@export var gravity: float = 9.82
@export var mouse_sensitivity: float = 0.002
@export var acceleration: float = 10.0
@export var friction: float = 8.0

var target_velocity: Vector3 = Vector3.ZERO
var current_speed: float = speed
var is_first_person: bool = true
var head: Node3D
var camera_1st: Camera3D
var spring_arm: SpringArm3D
var camera_3rd: Camera3D
var model: Node3D  # Reference to the character model
var animation_player: AnimationPlayer

var was_on_floor: bool = true
var jumping: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	head = $Head
	camera_1st = $Head/Camera
	spring_arm = $SpringArm
	camera_3rd = $SpringArm/Camera
	model = $Superhero_Male
	animation_player = $Superhero_Male/AnimationPlayer
	
	spring_arm.spring_length = 5.0
	spring_arm.collision_mask = 1
	switch_to_first_person()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_switch"):
		is_first_person = !is_first_person
		if is_first_person:
			switch_to_first_person()
		else:
			switch_to_third_person()
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if is_first_person:
			head.rotate_x(-event.relative.y * mouse_sensitivity)
			head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)
		else:
			spring_arm.rotation.x = clamp(spring_arm.rotation.x - event.relative.y * mouse_sensitivity, -1.0, 0.5)


func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("back"):
		input_dir.y += 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1
	input_dir = input_dir.normalized()
	
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed
	
	var target: Vector3 = direction * current_speed
	target_velocity.x = lerp(velocity.x, target.x, acceleration * delta)
	target_velocity.z = lerp(velocity.z, target.z, acceleration * delta)
	
	if input_dir == Vector2.ZERO:
		target_velocity.x = lerp(velocity.x, 0.0, friction * delta)
		target_velocity.z = lerp(velocity.z, 0.0, friction * delta)
	
	# Gravity
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		target_velocity.y = jump_strength
		jumping = true
		animation_player.play("Jump_Start")

	# Apply velocity
	velocity = target_velocity
	move_and_slide()

	# Landing detection
	if was_on_floor == false and is_on_floor() and not jumping:
		animation_player.play("Jump_Land")

	if is_on_floor():
		jumping = false

	# --- Animation State Machine ---
	if not is_on_floor():
		if velocity.y > 0:
			animation_player.play("Jump_Start")
		else:
			animation_player.play("Jump")
	else:
		var moving := input_dir.length() > 0.1
		if moving:
			if Input.is_action_pressed("sprint"):
				animation_player.play("Sprint")
			else:
				animation_player.play("Walk")
		else:
			animation_player.play("Idle")

	was_on_floor = is_on_floor()


func switch_to_first_person() -> void:
	camera_1st.current = true
	camera_3rd.current = false
	model.visible = false
	is_first_person = true


func switch_to_third_person() -> void:
	camera_3rd.current = true
	camera_1st.current = false
	model.visible = true
	is_first_person = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
