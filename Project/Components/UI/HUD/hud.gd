class_name HUD extends CanvasLayer

@onready var hp_bar: ProgressBar = $Control/TopContainer/StatsContainer/HpContainer/HpBar
@onready var sp_bar: ProgressBar = $Control/TopContainer/StatsContainer/SpContainer/SpBar
@onready var selectors : Array[TextureRect] = [
	$Control/TopContainer/ChordsContainer/ChordsSelector/ChordSelector1,
	$Control/TopContainer/ChordsContainer/ChordsSelector/ChordSelector2,
	$Control/TopContainer/ChordsContainer/ChordsSelector/ChordSelector3, 
	$Control/TopContainer/ChordsContainer/ChordsSelector/ChordSelector4,
	$Control/TopContainer/ChordsContainer/ChordsSelector/ChordSelector5,
	$Control/TopContainer/ChordsContainer/ChordsSelector/ChordSelector6,
	$Control/TopContainer/ChordsContainer/ChordsSelector/ChordSelector7	
	]	
@onready var chords : Array[TextureRect] = [
	$Control/TopContainer/ChordsContainer/Chords/Chord1,
	$Control/TopContainer/ChordsContainer/Chords/Chord2,
	$Control/TopContainer/ChordsContainer/Chords/Chord3,
	$Control/TopContainer/ChordsContainer/Chords/Chord4,
	$Control/TopContainer/ChordsContainer/Chords/Chord5,
	$Control/TopContainer/ChordsContainer/Chords/Chord6,
	$Control/TopContainer/ChordsContainer/Chords/Chord7
	]
@onready var chordsTexts : Array[Label] = [
	$Control/TopContainer/ChordsContainer/Chords/Chord1/ChordLabel1,
	$Control/TopContainer/ChordsContainer/Chords/Chord2/ChordLabel2,
	$Control/TopContainer/ChordsContainer/Chords/Chord3/ChordLabel3,
	$Control/TopContainer/ChordsContainer/Chords/Chord4/ChordLabel4,
	$Control/TopContainer/ChordsContainer/Chords/Chord5/ChordLabel5,
	$Control/TopContainer/ChordsContainer/Chords/Chord6/ChordLabel6,
	$Control/TopContainer/ChordsContainer/Chords/Chord7/ChordLabel7
	]
@onready var chords_count: Label = $Control/TopContainer/CounterContainers/ChordsCount
@onready var score_count: Label = $Control/TopContainer/CounterContainers/ScoreCount
@onready var chords_container: Control = $Control/TopContainer/ChordsContainer
@onready var counter_containers: HBoxContainer = $Control/TopContainer/CounterContainers
@onready var atack_bar: ProgressBar = $Control/TopContainer/StatsContainer/AtackContainer/AtackBar
@onready var dash_bar: ProgressBar = $Control/TopContainer/StatsContainer/DashContainer/DashBar
@onready var message_fader: Fader = $Message/MessageFader
@onready var message: Label = $Message/Message
@onready var atack_text: FadeLabel = $Control/TopContainer/Control/AtackText

var currentSelectedChord : int = 0
var currentChords : Array[int] = []
var messageTimer : float = 0

func _process(delta: float) -> void:
	if messageTimer > 0:
		messageTimer -= delta
		if messageTimer <= 0:
			messageTimer = 0
			message_fader.FadeOut(1)
			await message_fader.finished
			message.text = ""
func EnableCounters():
	chords_container.visible = true
	counter_containers.visible = true
	
func DisableCounters():
	chords_container.visible = false
	counter_containers.visible = false

func UpdateHp(value : int):
	hp_bar.value = value
	
func UpdateSp(value : int):
	sp_bar.value = value
	
func UpdateDash(value : float):
	dash_bar.value = value

func UpdateAtack(value : float):
	atack_bar.value = value
	
func UpdateChordsCount(value : int, of : int):
	chords_count.text = str(value) + "-" + str(of)
	
func UpdateScoreCount(value : int, of : int):
	score_count.text = str(value) + "-" + str(of)

func UnSelectChord(chord : int):
	if chord >= 1 and chord <= 7:
		var chordSelector = selectors[chord - 1]
		chordSelector.visible = false
		
func UnSelectAllChords():
	for selector in selectors:
		selector.visible = false
		
func SelectChord(chord : int):
	if chord >= 1 and chord <= 7:
		for selector in selectors:
			selector.visible = false
		var chordSelector = selectors[chord - 1]
		chordSelector.visible = true
		currentSelectedChord = chord - 1

func SetDeck(deck : ChordsDeck):
	var index = 0
	if deck:
		for chord in deck.Chords:
			var name = tr(chord.Name)
			name = name.replace(" ", "\n")		
			chordsTexts[index].text = name
			if index != currentSelectedChord:
				selectors[index].visible = false
			if not currentChords.any(func(c : int): return c == index ):
				chords[index].visible = false
			index += 1;
		chords[0].visible = true
	
func SetChordVisible(value : int):	
	chords[value - 1].visible = true
	currentChords.append(value - 1)
	
func ShowMessage(messageText : String):
	message.text = tr(messageText)
	messageTimer = 7
	message_fader.FadeIn(1)
	
func ShowAtackBonus(text : String):
	atack_text.text = text
	atack_text.FadeIn(0.2)
	await get_tree().create_timer(2).timeout
	atack_text.FadeOut(0.2)
	atack_text.text = ""
