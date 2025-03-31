extends Control
class_name SettingsMenu

signal Closed()

@onready var black_screen_fader: Fader = $BlackScreen/BlackScreenFader
@onready var main_fader: Fader = $Main/MainFader
@onready var language_opt: OptionButton = $Main/MenuContainer/LanguageGroup/LanguageOpt
@onready var music_slider: HSlider = $Main/MenuContainer/MusicGroup/MusicSlider
@onready var sfx_slider: HSlider = $Main/MenuContainer/SFXGroup/SfxSlider
@onready var black_screen: ColorRect = $BlackScreen

@export var BackTo : String = "res://Scenes/Menus/MainMenu.tscn"
@export var ShowBlackScreen : bool = true

var loaded = false
func _ready() -> void:
	Initialize()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Back()
	
func Initialize():		
	LoadOptions()
	if ShowBlackScreen:
		black_screen_fader.FadeOut()
		await black_screen_fader.finished
		main_fader.FadeIn()
	else:
		black_screen.visible = false
		main_fader.FadeIn()
		await main_fader.finished
	loaded = true
	language_opt.grab_focus()
	
func Back():	
	if ShowBlackScreen:
		black_screen_fader.FadeIn()		
		main_fader.FadeOut()
		await black_screen_fader.finished
	else:
		main_fader.FadeOut()
		await main_fader.finished
	Closed.emit()
	if not BackTo.is_empty():
		get_tree().change_scene_to_file(BackTo)
	else:
		queue_free()
	
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

func SaveOptions():
	GameOptions.SfxVolume = sfx_slider.value
	GameOptions.MusicVolume = music_slider.value
	GameOptions.SaveOptions()
		
func LoadOptions():
	match GameOptions.CurrentLanguage:
		"pt":
			language_opt.select(0)
		"es":
			language_opt.select(1)
		"en":
			language_opt.select(2)	
	sfx_slider.value = GameOptions.SfxVolume
	music_slider.value = GameOptions.MusicVolume


func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		SaveOptions()

func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		SaveOptions()

func _on_language_opt_item_selected(index: int) -> void:
	ChangeLanguage()
