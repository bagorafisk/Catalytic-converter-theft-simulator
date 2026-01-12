extends VehicleBody3D

signal exit_car

@export var engine_force_amount: float = 500.0
@export var brake_force_amount: float = 50.0
@export var steering_angle: float = 0.4

@onready var camera_3d: Camera3D = $Camera3D

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
		
	if Input.is_action_just_pressed("f"):
		camera_3d.current = false
		exit_car.emit()

	engine_force = throttle
	brake = brake_force_amount if Input.is_action_pressed("ui_select") else 0.0
	steering = steer


func _on_player_enter_car() -> void:
	camera_3d.current = true


func _on_area_3d_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
