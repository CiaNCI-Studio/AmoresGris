class_name Impact extends Node2D

@export var RootNote : NoteEvent
@export var ThirdNote : NoteEvent
@export var FifthNote : NoteEvent
@export var LifeTime : float = 5

@onready var root_particles: GPUParticles2D = $RootParticles
@onready var third_particles: GPUParticles2D = $ThirdParticles
@onready var fifth_particles: GPUParticles2D = $FifthParticles

var lifetimer : float = 0

func _ready() -> void:
	lifetimer = LifeTime
	if RootNote:
		root_particles.modulate = RootNote.NoteColor
	if ThirdNote:
		third_particles.modulate = ThirdNote.NoteColor
	if FifthNote:
		fifth_particles.modulate = FifthNote.NoteColor
	root_particles.emitting = true
	third_particles.emitting = true
	fifth_particles.emitting = true
	
func _process(delta: float) -> void:
	lifetimer -= delta
	if lifetimer <= 0:
		queue_free()
