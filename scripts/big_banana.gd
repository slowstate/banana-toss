extends RigidBody2D

@onready var timer = $Timer

var ROTATION_SPEED = deg_to_rad(180)
var SPEED = 500
var DIRECTION = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	linear_velocity = DIRECTION.normalized() * SPEED
	apply_force(linear_velocity)
	
	angular_velocity = ROTATION_SPEED
	apply_torque_impulse(angular_velocity)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_direction(direction : Vector2):
	DIRECTION = direction

func _on_body_entered(body):
	timer.start()

func _on_timer_timeout():
	queue_free()
