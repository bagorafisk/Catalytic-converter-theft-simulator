extends Control

@export var label_2: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_caar_wagon_off_car() -> void:
	$Label.hide()



func _on_caar_wagon_on_car() -> void:
	$Label.show()


func _on_player_on_cat() -> void:
	label_2.show()


func _on_player_off_cat() -> void:
	label_2.hide()
