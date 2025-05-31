class_name Door extends Node2D

@export var Id : int = 0
@export var IsOpen : bool = false
@export var TargetScene : String = ""
@export var CloseOnStart : bool = true
@onready var door: Sprite2D = $Door

var playerPresent : bool = false

func _ready() -> void:
	if CloseOnStart:
		IsOpen = true
		door.material.set("shader_parameter/dissolve_value", 0.0)
		Close()
		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("up") and playerPresent and TargetScene != "" and IsOpen:
		get_tree().change_scene_to_file(TargetScene)
		
func Open():
	if IsOpen:
		return
	var tween = create_tween()
	tween.tween_property(door, "material:shader_parameter/dissolve_value", 0.0, 1.0)
	await tween.finished
	IsOpen = true
	
func Close():
	if not IsOpen:
		return
	var tween = create_tween()
	tween.tween_property(door, "material:shader_parameter/dissolve_value", 1.0, 1.0)
	await tween.finished
	IsOpen = false
	
func _on_door_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		playerPresent = true

func _on_door_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		playerPresent = false
