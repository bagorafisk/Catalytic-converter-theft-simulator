extends VehicleBody3D

signal near_car

@export var engine_force_amount: float = 200.0
@export var brake_force_amount: float = 50.0
@export var steering_angle: float = 0.4

func _physics_process(delta: float) -> void:
	var throttle := 0.0
	var steer := 0.0

	if Input.is_action_pressed("ui_up"):
		throttle = engine_force_amount
	elif Input.is_action_pressed("ui_down"):
		throttle = -engine_force_amount

	if Input.is_action_pressed("ui_left"):
		steer = steering_angle
	elif Input.is_action_pressed("ui_right"):
		steer = -steering_angle
		
	if Input.is_action_just_pressed("reset"):
		position = position + Vector3(0.0, 1.0, 0.0)
		rotation = Vector3(0.0, 0.0, 0.0)

	engine_force = throttle
	brake = brake_force_amount if Input.is_action_pressed("ui_select") else 0.0
	steering = steer

func start_driving():
	$Camera3D.current = true
	set_process(true)

func stop_driving():
	$Camera3D.current = false
	set_process(false)


func _on_area_3d_area_entered(area: Area3D) -> void:
	near_car.emit()
