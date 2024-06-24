extends RigidBody2D

@onready var despawn_timer = $DespawnTimer
@onready var move_timer = $MoveTimer

var player_position
var vector_to_player

#region Stats
const MOVE_SPEED = 100
var health = 3
var move = true
#endregion

func _physics_process(delta):
	if move_timer.is_stopped():
		player_position = get_tree().get_first_node_in_group("Player").position
		vector_to_player = player_position - global_position
		rotation = vector_to_player.angle() + deg_to_rad(90)
		linear_velocity = vector_to_player.normalized() * MOVE_SPEED
		apply_force(linear_velocity)

func _on_body_entered(body):
	if move_timer.is_stopped() && despawn_timer.is_stopped():
		move_timer.start()
		health -= 1
		if health < 1 && despawn_timer.is_stopped():
			despawn_timer.start()

func _on_despawn_timer_timeout():
	queue_free()
