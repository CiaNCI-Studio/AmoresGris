extends Node2D

@onready var black_screen_fader: Fader = $CanvasLayer/BlackScreen/BlackScreenFader
@onready var main_fader: Fader = $CanvasLayer/Main/MainFader
@onready var back: Button = $CanvasLayer/Main/Back

func _ready() -> void:
	Initialize()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Back()
	
func Initialize():
	black_screen_fader.FadeOut()
	await black_screen_fader.finished
	main_fader.FadeIn()
	back.grab_focus()
		
func Back():
	main_fader.FadeOut()
	black_screen_fader.FadeIn()
	await main_fader.finished
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")
	
