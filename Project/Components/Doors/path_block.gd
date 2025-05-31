class_name PathBlock extends Node2D

@export var Id : int = 0
@export var IsOpen : bool = false
@onready var door: Sprite2D = $Door
@onready var blocker: StaticBody2D = $Blocker

func Open():
	if IsOpen:
		return
	var tween = create_tween()
	tween.tween_property(door, "material:shader_parameter/dissolve_value", 0.0, 1.0)
	await tween.finished
	blocker.collision_layer = 0
	IsOpen = true
	
func Close():
	if not IsOpen:
		return
	var tween = create_tween()
	tween.tween_property(door, "material:shader_parameter/dissolve_value", 1.0, 1.0)
	await tween.finished
	blocker.collision_layer = 3
	IsOpen = false
