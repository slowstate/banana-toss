extends RigidBody2D

@onready var timer = $Timer

const MOVE_SPEED = 120

# Called when the node enters the scene tree for the first time.
func _ready():
	var vector_to_banana_pile = Vector2(0,0) - global_position
	linear_velocity = vector_to_banana_pile.normalized() * MOVE_SPEED
	rotation = vector_to_banana_pile.angle() + deg_to_rad(90)
	apply_force(linear_velocity)

func _on_body_entered(body):
	if timer.is_stopped(): timer.start()

func _on_timer_timeout():
	queue_free()
