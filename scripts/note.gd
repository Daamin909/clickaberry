extends TextureRect

var speed := 400.0
var target_y := 800.0
var hit_window := 100.0
var key := ""

var hit := false
var printed := false

func _process(delta):
	global_position.y += speed * delta

	var OFFSET := -480.0  # tweak this number

	var dist = abs((global_position.y + OFFSET) - target_y)
	if key == "nine" and dist <= hit_window and not printed:
		print("NINE NOTE AT:", global_position)
		printed = true

	if global_position.y > target_y + hit_window:
		print("MISS:", key)
		queue_free()
		
func try_hit(input_key):
	if hit:
		return false
	
	if input_key != key:
		return false
	
	var dist = abs(global_position.y - target_y)	
	if dist <= hit_window:
		hit = true
		print("HIT:", key)
		queue_free()
		return true
	
	return false
