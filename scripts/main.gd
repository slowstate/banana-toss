extends Node2D

@onready var enemy_spawn_timer = $EnemySpawnTimer
@onready var high_score_label = $UserInterface/HighScoreLabel
@onready var score_label = $UserInterface/ScoreLabel
@onready var score_timer = $ScoreTimer
@onready var banana_pile = $BananaPile
@onready var restart_label = $UserInterface/RestartLabel
@onready var player = $Player

var enemy_scenes = [
	preload("res://scenes/enemies/enemy.tscn"),
	preload("res://scenes/enemies/shield_enemy.tscn"),
	preload("res://scenes/enemies/nimble_enemy.tscn"),
	preload("res://scenes/enemies/chasing_enemy.tscn")
	]

var big_powerup_scene = preload("res://scenes/powerups/big_powerup.tscn")
var piercing_powerup_scene = preload("res://scenes/powerups/piercing_powerup.tscn")

var difficulty = 0
var high_score = 0
var score = 0

var viewport_x
var viewport_y

signal pressedSpace
func _input(event):
	if event.is_action_pressed("ui_select"):
		pressedSpace.emit()

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_x = get_viewport().size.x
	viewport_y = get_viewport().size.y
	load_game()
	high_score_label.text = "High Score\n" + str(high_score)
	
func _on_enemy_spawn_timer_timeout():
	randomize()
	var spawned_enemy_scene = enemy_scenes[0].instantiate()
	if score >= 0 && score < 20:
		difficulty = 0
		enemy_spawn_timer.wait_time = 1
	elif score >= 20 && score < 40:
		score_label.add_theme_color_override("font_color", Color.ORANGE)
		difficulty = 1
		enemy_spawn_timer.wait_time = 0.9
		if randi() % 10 == 0:
			var spawned_powerup_scene = big_powerup_scene.instantiate()
			spawned_powerup_scene.picked_up.connect(_on_big_powerup)
			spawned_powerup_scene.position = Vector2(randi_range(-viewport_x/2,viewport_x/2), randi_range(-viewport_y/2,viewport_y/2))
			add_child(spawned_powerup_scene)
	elif score >= 40 && score < 60:
		score_label.add_theme_color_override("font_color", Color.RED)
		difficulty = 2
		enemy_spawn_timer.wait_time = 0.7
		match randi() % 8:
			0:
				var spawned_powerup_scene = big_powerup_scene.instantiate()
				spawned_powerup_scene.picked_up.connect(_on_big_powerup)
				spawned_powerup_scene.position = Vector2(randi_range(-viewport_x/2,viewport_x/2), randi_range(-viewport_y/2,viewport_y/2))
				add_child(spawned_powerup_scene)
			1:
				var spawned_powerup_scene = piercing_powerup_scene.instantiate()
				spawned_powerup_scene.picked_up.connect(_on_piercing_powerup)
				spawned_powerup_scene.position = Vector2(randi_range(-viewport_x/2,viewport_x/2), randi_range(-viewport_y/2,viewport_y/2))
				add_child(spawned_powerup_scene)
	elif score >= 60 && score < 80:
		score_label.add_theme_color_override("font_color", Color.DARK_RED)
		difficulty = 3
		enemy_spawn_timer.wait_time = 0.4
		match randi() % 5:
			0:
				var spawned_powerup_scene = big_powerup_scene.instantiate()
				spawned_powerup_scene.picked_up.connect(_on_big_powerup)
				spawned_powerup_scene.position = Vector2(randi_range(-viewport_x/2,viewport_x/2), randi_range(-viewport_y/2,viewport_y/2))
				add_child(spawned_powerup_scene)
			1:
				var spawned_powerup_scene = piercing_powerup_scene.instantiate()
				spawned_powerup_scene.picked_up.connect(_on_piercing_powerup)
				spawned_powerup_scene.position = Vector2(randi_range(-viewport_x/2,viewport_x/2), randi_range(-viewport_y/2,viewport_y/2))
				add_child(spawned_powerup_scene)
	
	spawned_enemy_scene = enemy_scenes[randi_range(0, difficulty)].instantiate()
	spawned_enemy_scene.position = random_vector2()
	add_child(spawned_enemy_scene)
	
func _on_big_powerup():
	player.set_powerup(1)

func _on_piercing_powerup():
	player.set_powerup(2)

func random_vector2():
	var x = randf_range(0, viewport_x/2)
	var y = randf_range(0, viewport_y/2)
	
	var dir = randi() % 4
	if dir == 0: x = x + viewport_x/2
	elif dir == 1: x = -(x+viewport_x/2)
	elif dir == 2: y = y + viewport_y/2
	elif dir == 3: y = -(y+viewport_y/2)
	
	return Vector2(x, y)

func _on_banana_pile_banana_pile_hit():
	if score > high_score:
		high_score_label.text = "High Score\n" + str(score)
		save_game()
	Engine.time_scale = 0
	restart_label.text = "Press SPACE to restart"
	await pressedSpace
	Engine.time_scale = 1
	restart_label.text = ""
	get_tree().reload_current_scene()

func _on_score_timer_timeout():
	score+=1
	score_label.text = "Score\n" + str(score)

#region Save logic
func save_game():
	var save_dict = {
		"high_score" : score
	}
	
	var saved_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	
	saved_game.store_line(json_string)

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	
	var saved_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while saved_game.get_position() < saved_game.get_length():
		var json_string = saved_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		
		high_score = node_data["high_score"]
#endregion
