extends VehicleBody3D

signal exit_car

@export var engine_force_amount: float = 200.0
@export var brake_force_amount: float = 50.0
@export var steering_angle: float = 0.4

@onready var camera_3d: Camera3D = $Camera3D

var in_car: bool = false

func _physics_process(delta: float) -> void:
	var throttle := 0.0
	var steer := 0.0
	if Input.is_action_pressed("ui_up"):
		throttle = engine_force_amount
	elif Input.is_action_pressed("ui_down"):
		throttle = -engine_force_amount / 1.5

	if Input.is_action_pressed("ui_left"):
		steer = steering_angle
	elif Input.is_action_pressed("ui_right"):
		steer = -steering_angle
		
	if Input.is_action_just_pressed("f"):
		in_car = false
		camera_3d.current = false
		exit_car.emit()
	if Input.is_action_pressed("reset"):
		rotation.x = 0
		rotation.z = 0
		position.y += 1

	engine_force = throttle
	brake = brake_force_amount if Input.is_action_pressed("ui_select") else 0.0
	steering = steer


func _on_player_enter_car() -> void:
	in_car = true
	camera_3d.current = true


func _on_area_3d_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
