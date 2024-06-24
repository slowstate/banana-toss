extends RigidBody2D

@onready var despawn_timer = $DespawnTimer

const MOVE_SPEED = 500
var vector_to_banana_pile

# Called when the node enters the scene tree for the first time.
func _ready():
	vector_to_banana_pile = Vector2(0,0) - global_position
	rotation = vector_to_banana_pile.angle() + deg_to_rad(90)

func _on_move_timer_timeout():
	if despawn_timer.is_stopped():
		linear_velocity = vector_to_banana_pile.normalized() * MOVE_SPEED
		apply_force(linear_velocity)

func _on_body_entered(body):
	if despawn_timer.is_stopped(): despawn_timer.start()

func _on_despawn_timer_timeout():
	queue_free()
