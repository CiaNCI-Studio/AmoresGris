extends Node

signal Finished

const MUSIC_BUS = "MUSIC"
const SFX_BUS = "SFX"

var streamPlayer : AudioStreamPlayer
var compositeAudio : CompositeAudio
var playState : int = 0
var currentBus : String = ""

func _ready() -> void:
	streamPlayer = AudioStreamPlayer.new()	
	streamPlayer.finished.connect(__Finished)
	add_child(streamPlayer)

func IsPlaying() -> bool:
	return streamPlayer.playing

func Play(bus : String, audio : CompositeAudio):
	currentBus = bus
	compositeAudio = audio
	if not compositeAudio.Intro.is_empty():
		__PlayIntro()
	else:
		__PlayLoop()	
	
func Pause(paused : bool):
	streamPlayer.stream_paused = paused
	
func Stop(playOutro : bool = true):
	if playOutro:
		__PlayOutro()
	else:
		streamPlayer.stop()		
		Finished.emit()
	
func __Finished():
	if playState == 0:
		__PlayLoop()
	elif playState == 2:
		playState = 0
		Finished.emit()		
			
func __PlayIntro():
	playState = 0
	var audioStream = load(compositeAudio.Intro) 
	audioStream.loop = false
	streamPlayer.bus = currentBus
	streamPlayer.stream = audioStream
	streamPlayer.play()
	
func __PlayLoop():
	playState = 1
	var audioStream = load(compositeAudio.Loop) 
	audioStream.loop = true
	streamPlayer.bus = currentBus
	streamPlayer.stream = audioStream
	streamPlayer.play()
	
func __PlayOutro():
	playState = 2
	var audioStream = load(compositeAudio.Outro) 
	audioStream.loop = false
	streamPlayer.bus = currentBus
	streamPlayer.stream = audioStream
	streamPlayer.play()
