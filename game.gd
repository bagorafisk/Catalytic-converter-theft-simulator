extends Node3D
@onready var inventory: Control = $CanvasLayer/inventory

var inventory_open: bool = false

var player_scene = preload("res://scenes/player.tscn")
var player: Node3D

func _on_caar_wagon_exit_car() -> void:
	player = player_scene.instantiate()
	add_child(player)
	
	player.position = $caar_wagon.position + Vector3(0,2,0)
	player.get_node("Head/Camera").current = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if inventory_open:
			inventory.hide()
			inventory_open = false
			print("hide")
		else:
			print("show")
			inventory.show()
			inventory_open = true
