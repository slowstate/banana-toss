extends RigidBody2D

@onready var timer = $Timer
@onready var shield_enemy_shield = $ShieldEnemyShield
@onready var pin_joint_2d = $PinJoint2D

const MOVE_SPEED = 70

# Called when the node enters the scene tree for the first time.
func _ready():
	var vector_to_banana_pile = Vector2(0,0) - global_position
	linear_velocity = vector_to_banana_pile.normalized() * MOVE_SPEED
	rotation = vector_to_banana_pile.angle() + deg_to_rad(90)
	apply_force(linear_velocity)

func _on_shield_enemy_body_body_entered(body):
	if pin_joint_2d != null:
		pin_joint_2d.queue_free()
	if timer.is_stopped(): timer.start()

func _on_timer_timeout():
	queue_free()
