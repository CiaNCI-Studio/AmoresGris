extends Node

const  OPTIONS_FOLDER_PATH : String = "user://Data/Settings/"
const  OPTIONS_FILE_NAME : String = "options.cfg"

@export var CurrentLanguage : String = "pt"
@export var SfxVolume : int = 100
@export var MusicVolume : int = 100

func _ready() -> void:
	__EnsureOptionsFolder()
	LoadOptions()

func SaveOptions():
	var optionsDic = {
		"CurrentLanguage": CurrentLanguage,
		"SfxVolume": SfxVolume,
		"MusicVolume": MusicVolume
	}
	var file = FileAccess.open(OPTIONS_FOLDER_PATH + OPTIONS_FILE_NAME, FileAccess.WRITE)	
	file.store_string(JSON.stringify(optionsDic))
	file.close()	
	UpdateAudioBus()

func LoadOptions():
	if FileAccess.file_exists(OPTIONS_FOLDER_PATH + OPTIONS_FILE_NAME):
		var file = FileAccess.open(OPTIONS_FOLDER_PATH + OPTIONS_FILE_NAME, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var optionsJson = JSON.parse_string(content)
		CurrentLanguage = optionsJson["CurrentLanguage"]
		SfxVolume = optionsJson["SfxVolume"]
		MusicVolume = optionsJson["MusicVolume"]		
		UpdateAudioBus()
	else:
		SaveOptions()

func UpdateAudioBus():
	var music_index= AudioServer.get_bus_index("MUSIC")
	if MusicVolume > 0:
		var musicBd = remap(MusicVolume, 0, 100, -40, 0) 
		AudioServer.set_bus_mute(music_index, false)	
		AudioServer.set_bus_volume_db(music_index, musicBd)	
	else:
		AudioServer.set_bus_mute(music_index, true)	
	
	var sfx_index= AudioServer.get_bus_index("SFX")
	if SfxVolume > 0:		
		var sfxBd = remap(SfxVolume, 0, 100, -40, 0)	
		AudioServer.set_bus_mute(sfx_index, false)		
		AudioServer.set_bus_volume_db(sfx_index, sfxBd)
	else:
		AudioServer.set_bus_mute(sfx_index, true)	

func __EnsureOptionsFolder():
	if not DirAccess.dir_exists_absolute(OPTIONS_FOLDER_PATH):
		DirAccess.make_dir_recursive_absolute(OPTIONS_FOLDER_PATH)
