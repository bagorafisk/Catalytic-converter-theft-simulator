extends Node2D


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
