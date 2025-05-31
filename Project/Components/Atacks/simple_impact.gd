class_name SimpleImpact extends Node2D

@export var LifeTime : float = 5
@onready var root_particles: GPUParticles2D = $RootParticles
var lifetimer : float = 0

func _ready() -> void:
	lifetimer = LifeTime
	root_particles.emitting = true

func _process(delta: float) -> void:
	lifetimer -= delta
	if lifetimer <= 0:
		queue_free()
