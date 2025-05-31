class_name Guide extends CharacterBody2D

enum GuideModes {
	Playing,
	Sitting,
	Standing
}

@export var InitialState : GuideModes = GuideModes.Playing
@export var Invert : bool = false

@onready var sprite: Node2D = $Sprite
@onready var playing_effect: GPUParticles2D = $PlayingEffect
@onready var animation_tree: AnimationTree = $AnimationTree

func _ready() -> void:
	if InitialState == GuideModes.Playing:		
		animation_tree.set("parameters/State/blend_amount", 1.0)
		playing_effect.emitting = true
	elif InitialState == GuideModes.Sitting:		
		animation_tree.set("parameters/State/blend_amount", 0.0)
		playing_effect.emitting = false
	else:
		animation_tree.set("parameters/State/blend_amount", -1.0)
		playing_effect.emitting = false
	if Invert:
		sprite.scale.x = -sprite.scale.x
		

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func StartPlaying():
	var tween = create_tween()
	tween.tween_property(animation_tree, "parameters/State/blend_amount", 1.0, 0.5)	
	await tween.finished
	playing_effect.emitting = true
	
func StopPlaying():
	playing_effect.emitting = false
	var tween = create_tween()
	tween.tween_property(animation_tree, "parameters/State/blend_amount", 0.0, 0.5)
