extends Node2D

var keys = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen"]


var font = load("res://assets/VT323-Regular.ttf")

var note_scene = preload("res://scenes/note.tscn")
var note2_scene = preload("res://scenes/note2.tscn")
var note3_scene = preload("res://scenes/note3.tscn")
var note4_scene = preload("res://scenes/note4.tscn")
var active_notes := {}
var hint_label: Label
var score_label: Label
var error_sound: AudioStreamPlayer
var camera: Camera2D
var camera_original_position: Vector2
var score := 0
var notes_spawned := 0
var base_speed := 250.0  

var patterns = [
	{ "key": "one" },
	{ "key": "two" },
	{ "key": "three" },
	{ "key": "four" },
	{ "key": "five" },
	{ "key": "six" },
	{ "key": "seven" },
	{ "key": "eight" },
	{ "key": "nine" },
	{ "key": "ten" },
	{ "key": "eleven" },
	{ "key": "twelve" },
	{ "key": "thirteen" },
	{ "key": "fourteen" },
	{ "key": "fifteen" },
	{ "key": "sixteen" },
	{ "key": "seventeen" },
	{ "key": "eighteen" },
]

func _ready() -> void:
	# Create hint label
	hint_label = Label.new()
	hint_label.position = Vector2(200, 0)
	hint_label.add_theme_font_override("font", font)
	hint_label.add_theme_font_size_override("font_size", 45)
	add_child(hint_label)
	# Create score label
	score_label = Label.new()
	score_label.position = Vector2(-400, 180)
	score_label.add_theme_font_size_override("font_size", 40)
	score_label.add_theme_font_override("font", font)
	add_child(score_label)
	update_score_label()
	
	# Setup error sound
	error_sound = AudioStreamPlayer.new()
	error_sound.stream = preload("res://assets/error.mp3")
	add_child(error_sound)
	
	# Get camera reference
	camera = get_node("Camera2D")
	camera_original_position = camera.position
	
	for key in keys:
		active_notes[key] = []
		set_visibility(key, true)  
	spawn_note("nine")
	update_hint_label()

func _process(_delta):
	for key in keys:
		if Input.is_action_just_pressed(key):
			handle_input(key)

func set_visibility(key, asf):
	var ting = get_node_or_null("things/" + key)
	if ting:
		ting.modulate.a = 1.0 if asf else 0.0

func get_note_scene_for_key(key):
	# note2.tscn for: two, four, five, seven, ten, twelve, thirteen, fifteen
	if key in ["two", "four", "five", "seven", "ten", "twelve", "thirteen", "fifteen"]:
		return note2_scene
	# note3.tscn for: seventeen
	elif key == "seventeen":
		return note3_scene
	# note4.tscn for: sixteen
	elif key == "sixteen":
		return note4_scene
	# note.tscn for all others
	else:
		return note_scene
		
func spawn_note(key):
	var scene = get_note_scene_for_key(key)
	var note = scene.instantiate()
	
	var key_node = get_node("things/" + key)
	
	# Use the key's REAL position
	var x = key_node.global_position.x
	var target_y = key_node.global_position.y
	
	# Calculate exponential speed increase
	var current_speed = base_speed * pow(1.0353, notes_spawned)
	notes_spawned += 1
	
	add_child(note)
	note.global_position = Vector2(x, -250)
	note.target_y = target_y
	note.key = key
	note.speed = current_speed
	
	active_notes[key].append(note)
	update_hint_label()
	
	# Hide the key when note spawns
	set_visibility(key, false)

func remove_note(note):
	# Store key before note is freed
	var note_key = note.key
	
	if note_key in active_notes:
		active_notes[note_key].erase(note)
	update_hint_label()
	
	# Wait for flash animation to complete
	await get_tree().create_timer(0.25).timeout
	
	# If there are still more notes for this key, hide it again after flash
	# Otherwise, keep it visible
	if note_key in active_notes:
		if active_notes[note_key].is_empty():
			set_visibility(note_key, true)
		else:
			set_visibility(note_key, false)
	
	await get_tree().create_timer(0.3).timeout  # 👈 ADD DELAY
	spawn_random_note.call_deferred()
	
func handle_input(key):
	# Check only the active notes for this key
	if key in active_notes:
		for note in active_notes[key]:
			if is_instance_valid(note) and not note.is_queued_for_deletion():
				if note.try_hit(key):
					flash_key(key)
					add_score(10)
					return
	
	print("MISS (no valid note):", key)
	on_miss()
func flash_key(key):
	var ting = get_node_or_null("things/" + key)
	if ting:
		ting.modulate.a = 1.0  # show
		
		await get_tree().create_timer(0.1).timeout
		
		ting.modulate.a = 0.0  # hide
		
		await get_tree().create_timer(0.1).timeout
		
		ting.modulate.a = 1.0  # show again


func update_hint_label():
	var active_keys = []
	for key in keys:
		if active_notes[key].size() > 0:
			active_keys.append(key.to_upper())
	
	if active_keys.is_empty():
		hint_label.text = ""
	else:
		hint_label.text = " ".join(active_keys)

func spawn_random_note():
	var pattern = patterns.pick_random()
	spawn_note.call_deferred(pattern.key)

func add_score(points: int):
	score += points
	update_score_label()
	
	# Check for game over
	if score <= -30:
		game_over()

func update_score_label():
	score_label.text = "Score: " + str(score)

func game_over():
	SceneManager.change_scene("res://scenes/game_over.tscn")

func on_miss():
	# Play error sound
	if error_sound:
		error_sound.play()
	
	# Shake screen
	shake_camera()
	
	# Deduct score
	add_score(-10)

func shake_camera():
	var shake_strength = 1.5
	var shake_duration = 0.2
	var shake_frequency = 30.0
	
	var elapsed = 0.0
	while elapsed < shake_duration:
		var offset_x = randf_range(-shake_strength, shake_strength)
		var offset_y = randf_range(-shake_strength, shake_strength)
		camera.offset = Vector2(offset_x, offset_y)
		
		await get_tree().create_timer(1.0 / shake_frequency).timeout
		elapsed += 1.0 / shake_frequency
	
	# Reset camera position
	camera.offset = Vector2.ZERO	
