extends Node2D

var keys = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen"]

var note_scene = preload("res://scenes/note.tscn")
var active_notes := {}  

func _ready() -> void:
	for key in keys:
		active_notes[key] = []
		set_visibility(key, true)  
	spawn_note("nine", -94, 200)

func _process(_delta):
	for key in keys:
		if Input.is_action_just_pressed(key):
			handle_input(key)

func set_visibility(key, asf):
	var ting = get_node_or_null("things/" + key)
	if ting:
		ting.modulate.a = 1.0 if asf else 0.0
		
func button_pressed(key):
	var ting = get_node("things/" + key)		
	ting.modulate.a = 1.0
	
func spawn_note(key, x, target_y):
	var note = note_scene.instantiate()
	
	note.position = Vector2(x, -250)
	note.target_y = target_y
	note.key = key
	
	add_child(note)
	active_notes[key].append(note)


func check_hit(key):
	var notes = active_notes[key]
	
	if notes.is_empty():
		print("MISS (no note)")
		return
	
	var best_note = null
	var best_distance = INF
	
	for note in notes:
		var dist = abs(note.position.y - note.target_y)
		
		if dist < best_distance:
			best_distance = dist
			best_note = note
	
	if best_distance <= best_note.hit_window:
		print("HIT")
		notes.erase(best_note)
		best_note.queue_free()
	else:
		print("MISS")


func remove_note(note):
	if note.key in active_notes:
		active_notes[note.key].erase(note)
		
func handle_input(key):
	for note in get_children():
		if note.has_method("try_hit"):
			if note.try_hit(key):
				flash_key(key)  # 👈 ADD THIS
				return
	
	print("MISS (no valid note):", key)
func flash_key(key):
	var ting = get_node_or_null("things/" + key)
	if ting:
		ting.modulate.a = 0.0  # hide
		
		await get_tree().create_timer(0.1).timeout  # 0.1 sec flash
		
		ting.modulate.a = 1.0  # show again
