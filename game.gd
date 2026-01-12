extends Node3D

var player_scene = preload("res://scenes/player.tscn")
var player: Node3D

func _on_caar_wagon_exit_car() -> void:
	player = player_scene.instantiate()
	add_child(player)

	player.get_node("SpringArm/Camera").current = true
