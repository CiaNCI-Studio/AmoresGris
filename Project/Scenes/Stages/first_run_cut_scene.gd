extends Node2D

const  NextScene = "res://Scenes/Stages/Controls.tscn"
@onready var fader: Fader = $Front/Control/BlackScreen/Fader

func _ready() -> void:
	fader.FadeOut()
	await fader.finished
	await get_tree().create_timer(5).timeout
	Finish()

func Finish():
	fader.FadeIn()
	await fader.finished
	get_tree().change_scene_to_file(NextScene)

func _on_skip_button_pressed() -> void:
	Finish()
