extends Node2D

const  NewGameScene = "res://Scenes/Stages/Stage1_Top.tscn"

@onready var black_screen_fader: Fader = $CanvasLayer/BlackScreen/BlackScreenFader
@onready var title: FadeLabel = $CanvasLayer/Main/Title
@onready var new_game_button: FadeButton = $CanvasLayer/Main/MenuContainer/NewGameButton
@onready var load_game_button: FadeButton = $CanvasLayer/Main/MenuContainer/LoadGameButton
@onready var settings_button: FadeButton = $CanvasLayer/Main/MenuContainer/SettingsButton
@onready var about_button: FadeButton = $CanvasLayer/Main/MenuContainer/AboutButton
@onready var exit_button: FadeButton = $CanvasLayer/Main/MenuContainer/ExitButton
@onready var language_label: FadeLabel = $CanvasLayer/Main/LanguageContainer/LanguageLabel
@onready var language_opt: OptionButton = $CanvasLayer/Main/LanguageContainer/LanguageOpt
@onready var language_opt_fader: Fader = $CanvasLayer/Main/LanguageContainer/LanguageOpt/LanguageOptFader
@onready var main_fader: Fader = $CanvasLayer/Main/MainFader

var saveSlots : Array[SaveFile] = []
var deleteSlotRequested : SaveFile
var loaded = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		BackButtons()
			

func _ready() -> void:
	Initialize()
	
func Initialize():
	LoadSlots()
	LoadLanguage()
	black_screen_fader.FadeOut()	
	await black_screen_fader.finished
	title.FadeIn()
	await get_tree().create_timer(0.5).timeout
	new_game_button.FadeIn()
	settings_button.FadeIn()
	about_button.FadeIn()
	exit_button.FadeIn()
	language_label.FadeIn()
	language_opt_fader.FadeIn()
	if len(saveSlots) > 0:
		load_game_button.FadeIn()
		load_game_button.grab_focus()	
	else:
		new_game_button.grab_focus()
	if not GlobalAudio.IsPlaying():
		var compositeAudio = CompositeAudio.new()
		compositeAudio.Intro = "res://Assets/Audio/Music/Opening-Intro.mp3"
		compositeAudio.Loop = "res://Assets/Audio/Music/Opening-Loop.mp3"
		compositeAudio.Outro = "res://Assets/Audio/Music/Opening-Outro.mp3"
		GlobalAudio.Play(GlobalAudio.MUSIC_BUS, compositeAudio)
	loaded = true
	
func Finilize(nextScene : String, stopMusic : bool = true):
	if stopMusic:
		GlobalAudio.Stop()
	title.FadeOut()	
	await get_tree().create_timer(0.5).timeout
	new_game_button.FadeOut()
	load_game_button.FadeOut()
	settings_button.FadeOut()
	about_button.FadeOut()
	exit_button.FadeOut()
	language_label.FadeOut()
	language_opt_fader.FadeOut()
	await exit_button.finished	
	black_screen_fader.FadeIn()	
	await black_screen_fader.finished
	if stopMusic:
		await GlobalAudio.Finished
	if not nextScene.is_empty():
		get_tree().change_scene_to_file(nextScene)
	else:
		get_tree().quit()

func ChangeLanguage():
	if not loaded:
		return
	match language_opt.selected:
		0:
			TranslationServer.set_locale("pt")
			GameOptions.CurrentLanguage = "pt"
		1:
			TranslationServer.set_locale("es")
			GameOptions.CurrentLanguage = "es"
		2:
			TranslationServer.set_locale("en")
			GameOptions.CurrentLanguage = "en"		
	GameOptions.SaveOptions()
	
func LoadLanguage():
	match GameOptions.CurrentLanguage:
		"pt":
			language_opt.select(0)
		"es":
			language_opt.select(1)
		"en":
			language_opt.select(2)	

func LoadSlots():
	saveSlots = SaveService.GetSlots()

func LoadSlot(slot : SaveFile):	
	SaveService.LoadGame(slot.SlotId)
	Finilize(SaveService.CurrentLoadedSlot.CurrentSceneId)

		
func DeleteSlot():
	if deleteSlotRequested:
		SaveService.DeleteSlot(deleteSlotRequested.SlotId)
		LoadSlots()
		if len(saveSlots) == 0:
			load_game_button.visible = false
			BackButtons()
		
func _on_new_game_button_pressed() -> void:
	SaveService.DeleteSlot(GameOptions.SAVE_SLOT_NAME)
	SaveService.NewSlot(GameOptions.SAVE_SLOT_NAME, GameOptions.SAVE_SLOT_NAME, NewGameScene)
	Finilize(NewGameScene)

func _on_load_game_button_pressed() -> void:
	SaveService.LoadGame(saveSlots[0].SlotId)
	Finilize(SaveService.CurrentLoadedSlot.CurrentSceneId)	

func _on_settings_button_pressed() -> void:
	Finilize("res://Scenes/Menus/SettingsMenu.tscn", false)

func _on_about_button_pressed() -> void:
	Finilize("res://Scenes/Menus/About.tscn", false)

func _on_exit_button_pressed() -> void:
	Finilize("")

func _on_language_opt_item_selected(index: int) -> void:
	ChangeLanguage()

func BackButtons() -> void:	
	main_fader.FadeIn()
	if len(saveSlots) > 0:		
		load_game_button.grab_focus()	
	else:
		new_game_button.grab_focus()

func _on_confirmation_dialog_confirmed() -> void:
	DeleteSlot()
