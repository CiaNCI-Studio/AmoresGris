extends Node2D

@onready var door_in: Door = $Map/DoorIn
@onready var door_out: Door = $Map/DoorOut
@onready var path_block: PathBlock = $Map/PathBlock
@onready var path_block_2: PathBlock = $Map/PathBlock2
@onready var path_block_3: PathBlock = $Map/PathBlock3
@onready var path_block_4: PathBlock = $Map/PathBlock4
@onready var checkPoints: Array[Marker2D] = [$Checkpoints/Checkpoint1, $Checkpoints/Checkpoint2, $Checkpoints/Checkpoint3]
@onready var player: Player = $Player
@onready var save_agent: SaveAgent = $SaveAgent
@onready var item_camera: PhantomCamera2D = $Cameras/ItemCamera
@onready var enemy_camera: PhantomCamera2D = $Cameras/EnemyCamera
@onready var guia: Guide = $Guia
@onready var guia_2: Guide = $Guia2
@onready var primer: Primer = $Enemies/Primer

var guideTriggered : bool = false
var  guide2Triggered : bool = false
var checkPoint1Triggered : bool = false

func _ready() -> void:
	save_agent.LoadSceneData.call_deferred()
	await get_tree().create_timer(0.5).timeout			
	Initialize()
	
func Initialize():
	Dialogic.signal_event.connect(_on_dialogic_signal)	
	if PlayerPersistentStates.CheckPoint == 1:		
		checkPoint1Triggered = true
		guideTriggered = true
		guia.queue_free()
		player.global_position = checkPoints[1].global_position
		player.EnableAtack()
		player.EnableDash()
		return 
		
	if PlayerPersistentStates.CheckPoint == 2:
		checkPoint1Triggered = true
		guideTriggered = true
		guia.queue_free()
		player.global_position = checkPoints[2].global_position
		player.EnableAtack()
		player.EnableDash()
		return
		
	if not SaveService.CurrentLoadedSlot:
		SaveService.NewSlot(GameOptions.SAVE_SLOT_NAME)
		SaveService.LoadGame(GameOptions.SAVE_SLOT_NAME)		
	save_agent.SaveSceneData()
	player.AddDeck("C")
	player.SelectDeck("C")
	player.CurrentStageChords = 1

func _on_dialogic_signal(argument:String):
	if argument == "ShowItem":
		item_camera.set_priority(10)
		await get_tree().create_timer(3.0).timeout
		item_camera.set_priority(0)
	if argument == "ShowEnemy":
		enemy_camera.set_priority(10)
		await get_tree().create_timer(4.0).timeout
		enemy_camera.set_priority(0)		
	if argument == "FinishTutorial":
		await get_tree().create_timer(0.5).timeout
		player.EnableControls()
		player.EnableDash()
		player.EnableAtack()		
		player.SelectChord(1)
	if argument == "FinishedGuide2":
		await get_tree().create_timer(0.5).timeout
		player.EnableControls()		
		player.EnableAtack()
		player.EnableDash()
	if argument == "finishedEndDialog":
		await get_tree().create_timer(0.5).timeout
		player.EnableControls()		
		player.EnableAtack()
		player.EnableDash()
		path_block_4.Open()
		door_out.Open()
		
func _on_check_point_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not checkPoint1Triggered:
		checkPoint1Triggered = true
		PlayerPersistentStates.CheckPoint = 1		
		guia.queue_free()
		save_agent.SaveSceneData(false)

func InitialInstructions():
	guideTriggered = true 
	player.DisableControls()
	await get_tree().create_timer(0.5).timeout	
	var dialog = Dialogic.start("Tutorial")	
	(dialog as CanvasLayer).layer = 999

func MiddleStageGuide():
	guide2Triggered = true 
	player.DisableControls()
	player.CanAtack = false
	await get_tree().create_timer(0.5).timeout	
	var dialog = Dialogic.start("Stage2Guide")	
	(dialog as CanvasLayer).layer = 999

func EndDialog():
	guide2Triggered = true 
	player.DisableControls()
	player.CanAtack = false
	await get_tree().create_timer(0.5).timeout	
	var dialog = Dialogic.start("Stage2End")	
	(dialog as CanvasLayer).layer = 999

func _on_guide_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not guideTriggered:
		InitialInstructions()


func _on_check_point_3_area_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		PlayerPersistentStates.CheckPoint = 2
		save_agent.SaveSceneData(false)


func _on_area_door_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and (body as Player).CurrentStageChords >= 4:
		path_block.Open()


func _on_area_door_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and (body as Player).CurrentStageChords == 7:
		path_block_3.Open()


func _on_area_close_door_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and path_block.IsOpen:
		path_block.Close()

func _on_area_close_door_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and path_block_3.IsOpen:
		path_block_3.Close()
		primer.StartCombat()


func _on_guide_2_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not guide2Triggered:
		MiddleStageGuide()

func _on_primer_finished_combat() -> void:
	EndDialog()
