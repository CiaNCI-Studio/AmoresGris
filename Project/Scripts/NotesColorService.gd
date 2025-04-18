extends Node

signal NotePressed(notes : NoteEvent)
signal NoteReleased(notes : NoteEvent)

var Notes : Array[Note] = []
var PlayingNotes : Array[NoteEvent] = []
var cadenceTimer : float = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMIDI:		
		var midiEvent = event as InputEventMIDI
		if midiEvent.message == MIDI_MESSAGE_NOTE_ON:
			NotePressed.emit(GetNote(midiEvent.pitch))		
		if midiEvent.message == MIDI_MESSAGE_NOTE_OFF:
			NoteReleased.emit(GetNote(midiEvent.pitch))

func _ready() -> void:
	OS.open_midi_inputs()
	__LoadNotes();
	
func _exit_tree() -> void:
	OS.close_midi_inputs()

func GetNote(code : int) -> NoteEvent:
	var notesFitered = Notes.filter(func(n : Note): return n.Code == code)
	if len(notesFitered) > 0:
		var result = NoteEvent.new()
		result.NoteBase = notesFitered[0]
		result.NoteColor = __GetNoteColor(result.NoteBase)
		result.NoteName = result.NoteBase.NoteName
		return result
	return null
		
func GetColor(code : int) -> Color:
	var noteEvent = GetNote(code)
	if not noteEvent:
		return Color.GRAY
	return __GetNoteColor(noteEvent.NoteBase)
	
func __GetNoteColor(note : Note) -> Color:
	if note != null:
		var hue = remap(note.Hue, 0, 360, 0.0, 1.0)
		var saturation = remap(note.Saturation, 0, 100, 0.0, 1.0)
		var value = remap(note.Value, 0, 100, 0.0, 1.0)
		return Color.from_hsv(hue, saturation, value)	
	return Color.GRAY
		
func __LoadNotes():
	var notesFile = FileAccess.open("res://Data/NotesColorData.json", FileAccess.READ)
	var notesDict = JSON.parse_string(notesFile.get_as_text())
	notesFile.close()	
	Notes = []
	for note in notesDict["Notes"]:
		var newNote = Note.new()
		newNote.Code = note["Code"]
		newNote.NoteName = note["NoteName"]
		newNote.Octave = note["Octave"]
		newNote.Hue = note["Hue"]
		newNote.Saturation = note["Saturation"]
		newNote.Value = note["Value"]
		Notes.append(newNote)
		
		
	
	
