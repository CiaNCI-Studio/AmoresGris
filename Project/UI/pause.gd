extends Control
class_name PauseMenu

@onready var fader: Fader = $Fader
@onready var black_scren_fader: Fader = $BlackScreen/BlackScrenFader
@onready var continue_button: FadeButton = $PauseGroup/MenuContainer/ContinueButton
@onready var options_button: FadeButton = $PauseGroup/MenuContainer/OptionsButton
@onready var main_menu_button: FadeButton = $PauseGroup/MenuContainer/MainMenuButton
@onready var pause_group: Control = $PauseGroup
@onready var pause_group_fader: Fader = $PauseGroup/PauseGroupFader

var settingsOpen : bool = false
var saveAgent : SaveAgent

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("start"):
		Pause()
	if (Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("menu")) and get_tree().paused and not settingsOpen:		
		Unpause()
		
func Pause():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	fader.FadeIn()
	await fader.finished
	continue_button.FadeIn()
	options_button.FadeIn()
	main_menu_button.FadeIn()
	continue_button.grab_focus()
	
func Unpause():
	continue_button.FadeOut()
	options_button.FadeOut()
	main_menu_button.FadeOut()
	fader.FadeOut()
	await fader.finished
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	
func GoToMainMenu():
	black_scren_fader.FadeIn()
	await black_scren_fader.finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")	

func ShowOptions():	
	var settingsMenu = load("res://UI/Settings.tscn").instantiate() as SettingsMenu
	settingsMenu.BackTo = ""
	settingsMenu.ShowBlackScreen = false
	settingsMenu.Closed.connect(CloseSettings)
	pause_group_fader.FadeOut()
	await pause_group_fader.finished
	settingsOpen = true
	add_child(settingsMenu)	

func CloseSettings():
	settingsOpen = false
	pause_group_fader.FadeIn()	
	
func _on_continue_button_pressed() -> void:
	Unpause()

func _on_options_button_pressed() -> void:
	ShowOptions()

func _on_main_menu_button_pressed() -> void:
	GoToMainMenu()
