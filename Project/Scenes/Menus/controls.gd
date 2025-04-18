extends Node2D


const  NextScene = "res://Scenes/Stages/Stage1.tscn"
const  WaitTime : float = 10
@onready var black_screen_fader: Fader = $Front/BlackScreen/BlackScreenFader


func _ready() -> void:
	Initialize()

func Initialize():
	black_screen_fader.FadeOut()
	await black_screen_fader.finished
	await get_tree().create_timer(WaitTime).timeout
	Finish()

func Finish():
	black_screen_fader.FadeIn()
	await black_screen_fader.finished	
	GameState.FirstRun = false
	get_tree().change_scene_to_file(NextScene)
	
func _on_skip_button_pressed() -> void:
	Finish()
