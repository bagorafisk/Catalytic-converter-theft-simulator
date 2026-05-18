extends CharacterBody3D

signal enter_car
signal on_cat
signal off_cat

var can_steal_cat = false

@export var speed: float = 1.5
@export var sprint_speed: float = 3.0
@export var jump_strength: float = 4.5
@export var gravity: float = 9.82
@export var mouse_sensitivity: float = 0.002
@export var acceleration: float = 10.0
@export var friction: float = 8.0

var target_velocity: Vector3 = Vector3.ZERO
var current_speed: float = speed
var is_first_person: bool = true

@onready var head: Node3D = $Head
@onready var camera_1st: Camera3D = $Head/Camera
@onready var spring_arm: SpringArm3D = $SpringArm
@onready var camera_3rd: Camera3D = $SpringArm/Camera
@onready var model: Node3D = $Superhero_Male
@onready var animation_player: AnimationPlayer = $Superhero_Male/AnimationPlayer

var was_on_floor: bool = true
var jumping: bool = false
var can_enter_car: bool = false

# --------------------------------------------------

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_arm.spring_length = 5.0
	spring_arm.collision_mask = 1
	switch_to_first_person()

# --------------------------------------------------

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_switch"):
		if is_first_person:
			switch_to_third_person()
		else:
			switch_to_first_person()

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)

		if is_first_person:
			head.rotate_x(-event.relative.y * mouse_sensitivity)
			head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)
		else:
			spring_arm.rotation.x = clamp(
				spring_arm.rotation.x - event.relative.y * mouse_sensitivity,
				-1.0,
				0.5
			)

# --------------------------------------------------

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.y = Input.get_action_strength("back") - Input.get_action_strength("forward")
	input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_dir = input_dir.normalized()

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed

	var target := direction * current_speed
	target_velocity.x = lerp(velocity.x, target.x, acceleration * delta)
	target_velocity.z = lerp(velocity.z, target.z, acceleration * delta)

	if input_dir == Vector2.ZERO:
		target_velocity.x = lerp(velocity.x, 0.0, friction * delta)
		target_velocity.z = lerp(velocity.z, 0.0, friction * delta)

	# Gravity
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	else:
		target_velocity.y = 0.0

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		target_velocity.y = jump_strength
		jumping = true
		animation_player.play("Jump_Start")

	velocity = target_velocity
	move_and_slide()

	# Landing detection
	if not was_on_floor and is_on_floor():
		animation_player.play("Jump_Land")
		jumping = false

	# ---------------- ANIMATIONS ----------------
	if not is_on_floor():
		if velocity.y > 0.0:
			animation_player.play("Jump_Start")
		else:
			animation_player.play("Jump")
	else:
		if input_dir.length() > 0.1:
			if Input.is_action_pressed("sprint"):
				animation_player.play("Sprint")
			else:
				animation_player.play("Walk")
		else:
			animation_player.play("Idle")

	was_on_floor = is_on_floor()

	# -------- ENTER CAR INPUT --------
	if Input.is_action_just_pressed("e") and can_enter_car:
		enter_car.emit()
		queue_free()

# --------------------------------------------------

func switch_to_first_person() -> void:
	camera_1st.make_current()
	model.visible = false
	is_first_person = true

func switch_to_third_person() -> void:
	camera_3rd.make_current()
	model.visible = true
	is_first_person = false

# --------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# --------------------------------------------------
# CAR DETECTION (USE BODY SIGNALS)
# --------------------------------------------------

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("car"):
		can_enter_car = true
		print("BODY ENTERED:", body.name)
	if body.is_in_group("cat"):
		can_steal_cat = true
		on_cat.emit()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("car"):
		can_enter_car = false
	if body.is_in_group("cat"):
		can_steal_cat = false
		off_cat.emit()
