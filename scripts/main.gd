extends Node2D

var keys = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen"]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass #   with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for key in keys:
		if Input.is_action_just_pressed(key):
			print(key)
