extends Node2D
@onready var save_agent: SaveAgent = $SaveAgent
@onready var guia: Guide = $Guia
@onready var player: Player = $Player
@onready var door_camera: PhantomCamera2D = $Cameras/DoorCamera
@onready var door: Door = $Map/Door

var introStarted : bool = false

func _ready() -> void:	
	save_agent.LoadSceneData.call_deferred()
	await get_tree().create_timer(0.5).timeout
	Initialize()
	
func Initialize():
	#Start Music
	Dialogic.signal_event.connect(_on_dialogic_signal)	
	if not SaveService.CurrentLoadedSlot:
		SaveService.NewSlot(GameOptions.SAVE_SLOT_NAME)
		SaveService.LoadGame(GameOptions.SAVE_SLOT_NAME)		
	save_agent.SaveSceneData()
	

func StartIntro():
	introStarted = true
	player.DisableControls()
	await get_tree().create_timer(2).timeout
	guia.StopPlaying()
	await get_tree().create_timer(0.5).timeout	
	#Stop Music
	var dialog = Dialogic.start("Intro")	
	(dialog as CanvasLayer).layer = 999

func _on_dialogic_signal(argument:String):
	if argument == "OpenDoor":
		guia.StartPlaying()
		await get_tree().create_timer(0.5).timeout
		#Start Music
		door_camera.set_priority(10)
		await get_tree().create_timer(1.5).timeout
		door.Open()
		await get_tree().create_timer(1.5).timeout
		door_camera.set_priority(0)
		await get_tree().create_timer(0.5).timeout
	if argument == "IntroFinish":
		await get_tree().create_timer(0.5).timeout
		player.EnableControls()
		
func _on_intro_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not introStarted:		
		StartIntro()
		
