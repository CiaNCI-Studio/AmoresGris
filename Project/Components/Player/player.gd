class_name Player extends CharacterBody2D

@onready var sampler_instrument: SamplerInstrument = $SamplerInstrument

func _ready() -> void:
	NotesColorService.NotePressed.connect(PlayNote)
	NotesColorService.NoteReleased.connect(ReleaseNote)
	
func PlayNote(note : NoteEvent):	
	sampler_instrument.play_note(note.NoteBase.NoteName, note.NoteBase.Octave)
		
func ReleaseNote(note : NoteEvent):
	pass
