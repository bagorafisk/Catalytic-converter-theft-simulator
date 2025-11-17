extends VehicleBody3D

@export var engine_force_amount: float = 500.0
@export var brake_force_amount: float = 50.0
@export var steering_angle: float = 0.4

func _physics_process(delta: float) -> void:
	var throttle := 0.0
	var steer := 0.0

	if Input.is_action_pressed("ui_up"):
		throttle = engine_force_amount
	elif Input.is_action_pressed("ui_down"):
		throttle = -engine_force_amount / 2.0

	if Input.is_action_pressed("ui_left"):
		steer = steering_angle
	elif Input.is_action_pressed("ui_right"):
		steer = -steering_angle

	engine_force = throttle
	brake = brake_force_amount if Input.is_action_pressed("ui_select") else 0.0
	steering = steer
