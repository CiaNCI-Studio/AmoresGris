class_name AtackBase extends RigidBody2D

@export var Power : int = 1
@export var LifeTime : float = 10


func _process(delta: float) -> void:
	LifeTime -= delta
	if LifeTime <= 0:
		queue_free()
