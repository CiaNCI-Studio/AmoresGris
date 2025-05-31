class_name PlayerAnimations extends Node2D

var parent : CharacterBody2D
@onready var animation_tree: AnimationTree = $AnimationTree
var originalScale : float


func _ready() -> void:
	parent = get_parent().get_parent()
	originalScale = scale.x

func _process(delta: float) -> void:	
	if parent:
		var speed = parent.velocity.x
		
		var animationSpeed = remap(abs(speed),0.0, 400.0, 0.0, 1.0)
		animation_tree.set("parameters/Speed/blend_position", animationSpeed)

func HangStart():
	animation_tree.set("parameters/Hang/blend_amount", 1.0)

func HangEnd():
	animation_tree.set("parameters/Hang/blend_amount", 0.0)

func Jump():
	animation_tree.set("parameters/Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func Atack():
	animation_tree.set("parameters/Atack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func Hit():
	animation_tree.set("parameters/Hit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func Dash():
	animation_tree.set("parameters/Dash/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func Landing():
	animation_tree.set("parameters/Landing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func JumpStart():
	animation_tree.set("parameters/Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
