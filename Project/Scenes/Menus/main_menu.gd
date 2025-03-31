extends Node2D

const  NewGameScene = "res://Scenes/Stages/FirstRunCutScene.tscn"

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
@onready var load_game_fader: Fader = $CanvasLayer/LoadGame/LoadGameFader
@onready var new_game_fader: Fader = $CanvasLayer/NewGame/NewGameFader
@onready var main_fader: Fader = $CanvasLayer/Main/MainFader
@onready var load_game: Control = $CanvasLayer/LoadGame
@onready var saves_stack: VBoxContainer = $CanvasLayer/LoadGame/ScrollContainer/SavesStack
@onready var new_name_warning: TextureRect = $CanvasLayer/NewGame/Container/NameGroup/NewNameWarning
@onready var new_game_name: TextEdit = $CanvasLayer/NewGame/Container/NameGroup/NewGameName
@onready var delete_confirmation_dialog: ConfirmationDialog = $CanvasLayer/DeleteConfirmationDialog
@onready var new_game: Control = $CanvasLayer/NewGame

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
	load_game_fader.FadeOut()
	new_game_fader.FadeOut()
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
	for child in saves_stack.get_children():
		child.queue_free()	
	saveSlots = SaveService.GetSlots()
	saveSlots.sort()
	for slot in saveSlots:
		var slotView = load("res://Components/UI/SaveSlot.tscn").instantiate() as SaveSlot
		slotView.saveSlot = slot
		slotView.Load.connect(LoadSlot)
		slotView.Delete.connect(AskDeleteSlot)
		saves_stack.add_child(slotView)
		
func NewGame():
	var name = new_game_name.text.strip_edges()
	new_name_warning.visible = false
	
	if name.is_empty():
		new_name_warning.tooltip_text = tr("TR_NAME_REQUIRED")
		new_name_warning.visible = true		
		return
	
	if saveSlots.any(func(item : SaveFile): return item.Name == name):
		new_name_warning.tooltip_text = tr("TR_DUPLICATED_NAME")
		new_name_warning.visible = true
		return
	
	var slotId = name.replace(" ", "_")
	SaveService.NewSlot(slotId, name, NewGameScene)
	Finilize(NewGameScene)
	
func LoadSlot(slot : SaveFile):	
	SaveService.LoadGame(slot.SlotId)
	Finilize(SaveService.CurrentLoadedSlot.CurrentSceneId)

func AskDeleteSlot(slot : SaveFile):
	deleteSlotRequested = slot
	delete_confirmation_dialog.visible = true
		
func DeleteSlot():
	if deleteSlotRequested:
		SaveService.DeleteSlot(deleteSlotRequested.SlotId)
		LoadSlots()
		if len(saveSlots) == 0:
			load_game_button.visible = false
			BackButtons()
		
func _on_new_game_button_pressed() -> void:
	new_game_fader.FadeIn()
	main_fader.FadeOut()
	new_game_name.grab_focus()

func _on_load_game_button_pressed() -> void:
	load_game_fader.FadeIn()	
	main_fader.FadeOut()
	var slots = saves_stack.get_children()
	if len(slots) > 0:
		(slots[0] as SaveSlot).Focus()

func _on_settings_button_pressed() -> void:
	Finilize("res://Scenes/Menus/SettingsMenu.tscn", false)

func _on_about_button_pressed() -> void:
	Finilize("res://Scenes/Menus/About.tscn", false)

func _on_exit_button_pressed() -> void:
	Finilize("")

func _on_language_opt_item_selected(index: int) -> void:
	ChangeLanguage()

func BackButtons() -> void:
	load_game_fader.FadeOut()
	new_game_fader.FadeOut()
	main_fader.FadeIn()
	if len(saveSlots) > 0:		
		load_game_button.grab_focus()	
	else:
		new_game_button.grab_focus()
	

func _on_create_new_game_pressed() -> void:
	NewGame()

func _on_confirmation_dialog_confirmed() -> void:
	DeleteSlot()

func _on_confirmation_dialog_canceled() -> void:
	deleteSlotRequested = null
	delete_confirmation_dialog.visible = false
