extends Node2D
@onready var grinder: Sprite2D = $Sprite2D2
@onready var sparks: Sprite2D = $Sprite2D2/Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	grinder.global_position = get_global_mouse_position()
	sparks.global_position = get_global_mouse_position()
	
	if Input.is_action_pressed("LMB"):
		sparks.show()
	else:
		sparks.hide()
