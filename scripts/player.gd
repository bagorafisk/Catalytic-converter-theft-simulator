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
var model: Node3D  # Reference to the Superhero_Male model

func _ready() -> void:
	# Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Get node references
	head = $head
	camera_1st = $head/Camera3D
	spring_arm = $SpringArm
	camera_3rd = $SpringArm/Camera
	model = $Superhero_Male  # Adjust path based on your scene hierarchy
	
	# Initial setup
	spring_arm.spring_length = 5.0
	spring_arm.collision_mask = 1
	switch_to_first_person()  # Start in 1st person

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_switch"):  # Toggle perspective with Enter key
		is_first_person = !is_first_person
		if is_first_person:
			switch_to_first_person()
		else:
			switch_to_third_person()
	
	# Handle mouse movement based on current perspective
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if is_first_person:
			rotate_y(-event.relative.x * mouse_sensitivity)
			head.rotate_x(-event.relative.y * mouse_sensitivity)
			head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)
		else:
			rotate_y(-event.relative.x * mouse_sensitivity)
			spring_arm.rotation.x = clamp(spring_arm.rotation.x - event.relative.y * mouse_sensitivity, -1.0, 0.5)

func _physics_process(delta: float) -> void:
	# Handle movement direction
	var input_dir: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("back"):
		input_dir.y += 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1
	
	input_dir = input_dir.normalized()
	
	# Convert 2D input to 3D direction
	var direction: Vector3 = Vector3.ZERO
	if is_first_person:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else:
		direction = (spring_arm.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		direction = direction.rotated(Vector3.UP, rotation.y)
	
	# Handle sprinting
	current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed
	
	# Smooth movement with acceleration and friction
	var target: Vector3 = direction * current_speed
	target_velocity.x = lerp(velocity.x, target.x, acceleration * delta)
	target_velocity.z = lerp(velocity.z, target.z, acceleration * delta)
	
	if input_dir == Vector2.ZERO:
		target_velocity.x = lerp(velocity.x, 0.0, friction * delta)
		target_velocity.z = lerp(velocity.z, 0.0, friction * delta)
	
	# Apply gravity
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	
	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		target_velocity.y = jump_strength
	
	# Apply velocity and move
	velocity = target_velocity
	move_and_slide()

func switch_to_first_person() -> void:
	camera_1st.current = true
	camera_3rd.current = false
	model.visible = false  # Hide model in 1st person
	is_first_person = true

func switch_to_third_person() -> void:
	camera_3rd.current = true
	camera_1st.current = false
	model.visible = true  # Show model in 3rd person
	is_first_person = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
