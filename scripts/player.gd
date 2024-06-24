extends CharacterBody2D

@onready var timer = $Timer
@onready var powerup_timer = $PowerupTimer

var banana_scene = preload("res://scenes/banana.tscn")
var big_banana_scene = preload("res://scenes/big_banana.tscn")
var piercing_banana_scene = preload("res://scenes/piercing_banana.tscn")

var MOVE_SPEED = 300.0
var banana_cooldown_ready = true
var powerup = 0 #0 = none, 1 = big, 2 = piercing

func _ready():
	pass
	
func _physics_process(delta):
	if 	Engine.time_scale > 0:
		if Input.is_action_pressed("player_left_click"):
			if banana_cooldown_ready:
				throw_banana()
				banana_cooldown_ready = false
				timer.wait_time = 0.2
				timer.start()
		
		var move_vec = Vector2()
		if Input.is_action_pressed("player_move_up"):
			set_rotation(deg_to_rad(0))
			move_vec.y -= 1
		if Input.is_action_pressed("player_move_left"):
			set_rotation(deg_to_rad(270))
			move_vec.x -= 1
		if Input.is_action_pressed("player_move_down"):
			set_rotation(deg_to_rad(180))
			move_vec.y += 1
		if Input.is_action_pressed("player_move_right"):
			set_rotation(deg_to_rad(90))
			move_vec.x += 1
		move_vec = move_vec.normalized()
		
		move_and_collide(move_vec * MOVE_SPEED * delta)

func throw_banana():
	var thrown_banana = banana_scene.instantiate()
	if powerup == 1:
		thrown_banana = big_banana_scene.instantiate()
	if powerup == 2:
		thrown_banana = piercing_banana_scene.instantiate()
	
	thrown_banana.position = global_position
	thrown_banana.set_direction(get_global_mouse_position() - thrown_banana.position)
	get_tree().root.get_child(0).add_child(thrown_banana)

func _on_timer_timeout():
	banana_cooldown_ready = true

func set_powerup(power_up_id):
	powerup = power_up_id
	powerup_timer.start()

func _on_powerup_timer_timeout():
	powerup = 0
