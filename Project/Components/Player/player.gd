class_name Player extends CharacterBody2D

@onready var sampler_instrument: SamplerInstrument = $SamplerInstrument
@onready var sprite_group: Node2D = $Sprite
@onready var atack_spawn_point: Marker2D = $Sprite/AtackSpawnPoint
@onready var hud: HUD = $HUD
@onready var player_anim: Node2D = $SubViewport/PlayerAnim
@onready var walk_effect: GPUParticles2D = $Effects/WalkEffect
@onready var dash_effect: GPUParticles2D = $Effects/DashEffect
@onready var special_effect: GPUParticles2D = $Effects/SpecialEffect
@onready var damage_effect: GPUParticles2D = $Effects/DamageEffect
@onready var side_scrolling_controler_2d: SideScrollingControler2D = $SideScrollingControler2D

@export var Hp : int = 100
@export var MaxHp : int = 100
@export var Sp : int = 0
@export var MaxSp : int = 100
@export var AtackCadenceTime : float = 1
@export var SpecialLevel : int = 2
@export var CurrentDecks : Array[ChordsDeck] = []
@export var SelectedDeck : ChordsDeck
@export var ScoreCollection : Array[String] = []
@export var FoundScores : Array[String] = []
@export var FoundKeys : Array[String] = []
@export var CanAtack : bool = false
@export var CanDash : bool = false
@export var AvailibleChords : Array[int] = []

var atackCadenceTimer : float = 0
var CurrentStageChords : int = 1
var CurrentStageScore : int = 0
var walkSFXcount : int = 0
var walkSFXDelay : float = 0.1
var walkSFXDelayTimer : float = 0
var selectedChord : Chord 
var currentSelectedChord : int = 1
var lastChordPlayed : int  = 0
var manualNotes : Array[NoteEvent] = []
var manualNotesDelayTime : float = 1.0
var manualNotesDelayTimer : float = 0

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("action") and CanAtack:
		Atack()
	if Input.is_action_just_pressed("special"):
		Special()
	if Input.is_action_just_pressed("chord1"):
		SelectChord(1)
	if Input.is_action_just_pressed("chord2"):
		SelectChord(2)
	if Input.is_action_just_pressed("chord3"):
		SelectChord(3)
	if Input.is_action_just_pressed("chord4"):
		SelectChord(4)
	if Input.is_action_just_pressed("chord5"):
		SelectChord(5)
	if Input.is_action_just_pressed("chord6"):
		SelectChord(6)
	if Input.is_action_just_pressed("chord7"):
		SelectChord(7)
		
	if Input.is_action_just_pressed("inventoryRight"):
		currentSelectedChord += 1
		if currentSelectedChord > 7:
			currentSelectedChord  = 1
		SelectChord(currentSelectedChord)
	
	if Input.is_action_just_pressed("inventoryLeft"):
		currentSelectedChord -= 1
		if currentSelectedChord < 1:
			currentSelectedChord = 7
		SelectChord(currentSelectedChord)

func _ready() -> void:
	LoadPersistentState()
	UpddateHud()

func _process(delta: float) -> void:
	if velocity.x > 0:
		sprite_group.scale.x = abs(sprite_group.scale.x)
	elif velocity.x < 0:
		sprite_group.scale.x = -abs(sprite_group.scale.x)
			
	walk_effect.emitting = abs(velocity.x) > 30 and is_on_floor()
	
	if atackCadenceTimer >= 0:
		atackCadenceTimer -= delta
		var atackValue = remap(atackCadenceTimer, 0, AtackCadenceTime, 100, 0)		
		hud.UpdateAtack(atackValue)
		
	HandleManualNotes()
	
	#WalkSFX(delta)

func TakeDamage(value : int):
	PlayNote(NotesColorService.GetNoteByName("C", 3))
	PlayNote(NotesColorService.GetNoteByName("F", 3))
	damage_effect.emitting = true
	player_anim.Hit()
	Hp -= value
	if Hp <= 0:
		DisableControls()
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.BLACK, 1.0)		
		await tween.finished
		get_tree().change_scene_to_file("res://Scenes/Menus/GameOver.tscn")
		
	SavePersistentState()
	UpddateHud()
		
func Recover(value : int):	
	Hp += value
	if Hp > MaxHp:
		Hp = MaxHp
	SavePersistentState()
	UpddateHud()
	
func LoadPersistentState():
	Hp = PlayerPersistentStates.Hp
	AtackCadenceTime = PlayerPersistentStates.AtackCadenceTime
	SpecialLevel = PlayerPersistentStates.SpecialLevel
	CanDash = PlayerPersistentStates.CanDash 
	CanAtack = PlayerPersistentStates.CanAtack
	ScoreCollection = []
	AvailibleChords = []
	if PlayerPersistentStates.ScoreCollection != "":
		ScoreCollection.assign(PlayerPersistentStates.ScoreCollection.split(";"))

	if PlayerPersistentStates.AvailibleChords != "":
		var tempArray : Array[String] = []
		tempArray.assign(PlayerPersistentStates.AvailibleChords.split(";"))
		AvailibleChords.assign(tempArray.map(func(i : String): return int(i)))
		
	var currentDecks = PlayerPersistentStates.CurrentDecks.split(";")
	for deck in currentDecks:
		var filteredDecks = NotesColorService.Decks.filter(func(d : ChordsDeck): return d.Code == deck)
		if len(filteredDecks) > 0:
			CurrentDecks.append(filteredDecks[0])
			
	var filteredSelectedDecks = CurrentDecks.filter(func(d : ChordsDeck): return d.Code == PlayerPersistentStates.SelectedDeck)
	if len(filteredSelectedDecks) > 0:
		SelectedDeck = filteredSelectedDecks[0]	
	CurrentStageScore = len(ScoreCollection)
	CurrentStageChords = len(AvailibleChords)
	hud.UpdateChordsCount(CurrentStageChords, 7)
	hud.UpdateScoreCount(CurrentStageScore, 7)
	
func SavePersistentState():
	PlayerPersistentStates.Hp = Hp
	PlayerPersistentStates.MaxHp = MaxHp
	PlayerPersistentStates.AtackCadenceTime = AtackCadenceTime
	PlayerPersistentStates.SpecialLevel = SpecialLevel
	PlayerPersistentStates.CurrentDecks = ";".join(CurrentDecks.map(func(d : ChordsDeck): return d.Code))	
	if SelectedDeck:
		PlayerPersistentStates.SelectedDeck = SelectedDeck.Code
	else:
		PlayerPersistentStates.SelectedDeck = ""
	PlayerPersistentStates.ScoreCollection = ";".join(ScoreCollection)	
	PlayerPersistentStates.CanDash = CanDash
	PlayerPersistentStates.CanAtack = CanAtack
	PlayerPersistentStates.AvailibleChords = ";".join(AvailibleChords)
	
func SelectDeck(deckCode : String) -> ChordsDeck:
	var filteredDecks = CurrentDecks.filter(func(d : ChordsDeck): return d.Code == deckCode)
	if len(filteredDecks) > 0:
		SelectedDeck = filteredDecks[0]		
		AvailibleChords = [1]
		hud.SetChordVisible(1)
		SelectChord(1)
		SavePersistentState()		
		return SelectedDeck
	return null

func SelectChord(number : int) -> bool:
	if SelectedDeck and AvailibleChords.has(number):
		atackCadenceTimer = 0
		currentSelectedChord = number
		selectedChord = SelectedDeck.Chords[number - 1]
		hud.SelectChord(number)
		return true
	return false
	
func AddDeck(deckCode : String) -> bool:
	var filteredDecks = NotesColorService.Decks.filter(func(d : ChordsDeck): return d.Code == deckCode)
	if len(filteredDecks) > 0:
		CurrentDecks.append(filteredDecks[0])
		SavePersistentState()
		return true
	return false
	
func AddScore(score : String) -> bool:
	var filteredScores = ScoreCollection.filter(func(s : String): return s == score)
	if len(filteredScores) == 0:
		ScoreCollection.append(score)		
		UpddateHud()
		return true
	return false	
	
func GetItem(item: ItemBase):
	if item.Type == ItemBase.ItemTypes.ChordItem:
		var itemChord = SelectedDeck.Chords.filter(func(c :Chord): return c.Code == item.Value)
		if len(itemChord) > 0:
			FoundKeys.append(item.Value)
			CurrentStageChords += 1;			
			hud.UpdateChordsCount(CurrentStageChords, 7)
			var chordNumber = SelectedDeck.Chords.find(itemChord[0]) + 1
			hud.SetChordVisible(chordNumber)
			AvailibleChords.append(chordNumber)
	elif item.Type == ItemBase.ItemTypes.ScoreItem:
		CurrentStageScore += 1;
		FoundScores.append(item.Value)
		hud.UpdateScoreCount(CurrentStageScore, 3)
		hud.ShowMessage(item.Value)
	item.queue_free()
		
func Special():
	if Sp < MaxSp:
		return
	return	
	
func Atack(manualBonus : bool = false):
	if atackCadenceTimer > 0:
		return
	if not selectedChord:
		SelectChord(1)
	atackCadenceTimer = AtackCadenceTime
	player_anim.Atack()
	var instance = load("res://Components/Atacks/NormalAtack.tscn").instantiate() as NormalAtack
	instance.RootNote = selectedChord.Notes[0]
	instance.ThirdNote = selectedChord.Notes[1]
	instance.FifthNote = selectedChord.Notes[2]	
	instance.Power = GetAtackPower(manualBonus)		
	instance.scale = instance.scale * -sprite_group.scale.x
	get_parent().add_child(instance)
	instance.global_position = atack_spawn_point.global_position
	instance.apply_impulse(Vector2.LEFT * 500 * -sprite_group.scale.x)
	PlayChord(selectedChord)
	
func PlayChord(chord : Chord):
	for note in chord.Notes:
		PlayNote(note)		
		await get_tree().create_timer(0.01).timeout

func HandleManualNotes():
	if not CanAtack:
		return
	if len(NotesColorService.PlayingNotes) >= 3:
		var filtered = SelectedDeck.Chords
		for note in NotesColorService.PlayingNotes:
			filtered = filtered.filter(func(c : Chord) : return c.Notes.any(func(f : NoteEvent): return f.Code == note.Code))			
		var tempChord = Chord.new()
		tempChord.Notes.append(NotesColorService.PlayingNotes[0])
		tempChord.Notes.append(NotesColorService.PlayingNotes[1])
		tempChord.Notes.append(NotesColorService.PlayingNotes[2])
		NotesColorService.PlayingNotes = []
		if len(filtered) == 1:
			var selectedNumber = SelectedDeck.Chords.find(filtered[0])
			if SelectedDeck and AvailibleChords.has(selectedNumber + 1):
				atackCadenceTimer = 0
				currentSelectedChord = selectedNumber + 1
				tempChord.Code = filtered[0].Code
				tempChord.Name = filtered[0].Name
				selectedChord = tempChord
				hud.SelectChord(selectedNumber + 1)
				Atack(true)
			
func PlayNote(note : NoteEvent, octave : int = -1):	
	if octave == -1:
		sampler_instrument.play_note(note.NoteBase.Code, note.NoteBase.Octave)
	else:
		sampler_instrument.play_note(note.NoteBase.Code, octave)
		
func GetAtackPower(manualBonus : bool) -> int:
	var result = 5	
	var text = ""
	if manualBonus:
		result += 5
		text += tr("TR_KEYS") + " +5\n"		
	if currentSelectedChord != lastChordPlayed and lastChordPlayed != 0:
		var distance = abs(lastChordPlayed - currentSelectedChord)
		match distance:
			1:
				result += 2
				text += tr("TR_COMBO") + " +2"		
			2:
				result += 3
				text += tr("TR_COMBO") + " +3"		
			3:
				result += 5
				text += tr("TR_COMBO") + " +5"		
			4: 
				result += 10
				text += tr("TR_COMBO") + " +10"		
			5: 
				result += 5
				text += tr("TR_COMBO") + " +5"		
			6: 
				result += 3	
				text += tr("TR_COMBO") + " +3"		
	lastChordPlayed = currentSelectedChord
	if text != "":
		hud.ShowAtackBonus(text)
	return result
	
func UpddateHud():
	if not CanAtack:
		hud.DisableCounters()
	else:
		hud.EnableCounters()
	hud.UpdateHp(Hp)
	hud.UpdateSp(Sp)
	hud.SetDeck(SelectedDeck)
	for number in AvailibleChords:
		hud.SetChordVisible(number)

func EnableDash():
	CanDash = true
	SavePersistentState()
	side_scrolling_controler_2d.CanDash = CanDash
	
func EnableAtack():
	CanAtack = true
	SavePersistentState()
	UpddateHud()
	

func WalkSFX(delta : float):
	if abs(velocity.x) > 30 and is_on_floor():	
		if walkSFXDelayTimer <= 0:
			walkSFXDelayTimer = walkSFXDelay
			if SelectedDeck:
				sampler_instrument.play_note(SelectedDeck.Chords[0].Notes[walkSFXcount].Code, 7)
				walkSFXcount += 1
				if walkSFXcount > 2:
					walkSFXcount = 0
		else:
			walkSFXDelayTimer -= delta
		
func DisableControls():
	velocity = Vector2.ZERO
	side_scrolling_controler_2d.InputEnabled = false
	
func EnableControls():
	side_scrolling_controler_2d.InputEnabled = true
		
func _on_side_scrolling_controler_2d_dash_start() -> void:
	dash_effect.emitting = true
	player_anim.Dash()

func _on_side_scrolling_controler_2d_hit_hang() -> void:
	player_anim.HangStart()

func _on_side_scrolling_controler_2d_leave_hang() -> void:
	player_anim.HangEnd()

func _on_side_scrolling_controler_2d_jump_start() -> void:
	player_anim.Jump()


func _on_contact_area_body_entered(body: Node2D) -> void:
	if body is ItemBase:
		GetItem(body as ItemBase)	


func _on_side_scrolling_controler_2d_dash_recovery(time: float) -> void:
	var dashValue = remap(time, 0, side_scrolling_controler_2d.DashRecoverTime, 100, 0)		
	hud.UpdateDash(dashValue)
