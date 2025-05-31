extends Control
class_name GameOver

@onready var fader: Fader = $Fader
@onready var black_scren_fader: Fader = $BlackScreen/BlackScrenFader
@onready var main_menu_button: FadeButton = $GameOverGroup/MenuContainer/MainMenuButton


func _ready() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	fader.FadeIn()
	main_menu_button.FadeIn()
	main_menu_button.grab_focus()

func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ui_cancel")):		
		GoToMainMenu()
		
func GoToMainMenu():
	black_scren_fader.FadeIn()
	await black_scren_fader.finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")	

func _on_main_menu_button_pressed() -> void:
	GoToMainMenu()
