extends Node

const BASE_OCTAVE : int = 4

signal NotePressed(notes : NoteEvent)
signal NoteReleased(notes : NoteEvent)

var Notes : Array[Note] = []
var Chords : Array[Chord] = []
var Decks : Array[ChordsDeck] = []
var PlayingNotes : Array[NoteEvent] = []
var cadenceTimer : float = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMIDI:		
		var midiEvent = event as InputEventMIDI	
		if midiEvent.message == MIDI_MESSAGE_NOTE_ON:	
			var note = 	GetNote(midiEvent.pitch)
			PlayingNotes.append(note)	
			NotePressed.emit(note)		
		if midiEvent.message == MIDI_MESSAGE_NOTE_OFF:
			var note = 	GetNote(midiEvent.pitch)
			PlayingNotes.remove_at(PlayingNotes.find(note))
			NoteReleased.emit(note)

func _ready() -> void:
	OS.open_midi_inputs()
	__LoadNotes()
	__LoadChords()
	__LoadDecks()
	
func _exit_tree() -> void:
	OS.close_midi_inputs()

func GetNoteByName(name : String, octave : int) -> NoteEvent:
	var notesFitered = Notes.filter(func(n : Note): return n.Code == name and n.Octave == octave)
	if len(notesFitered) > 0:
		var result = NoteEvent.new()
		result.NoteBase = notesFitered[0]
		result.NoteColor = __GetNoteColor(result.NoteBase)
		result.Code = result.NoteBase.Code
		result.NoteName = "TR_NOTE_" + result.NoteBase.Code.to_upper()
		return result
	return null
	
func GetChordByCode(code : String) -> Chord:
	var chordsFitered = Chords.filter(func(c : Chord): return c.Code == code)
	if len(chordsFitered) > 0:
		return chordsFitered[0]		
	return null

func GetNote(code : int) -> NoteEvent:
	var notesFitered = Notes.filter(func(n : Note): return n.MidiCode == code)
	if len(notesFitered) > 0:
		var result = NoteEvent.new()
		result.NoteBase = notesFitered[0]
		result.NoteColor = __GetNoteColor(result.NoteBase)
		result.Code = result.NoteBase.Code
		result.NoteName = "TR_NOTE_" + result.NoteBase.Code.to_upper()
		return result
	return null
	
func GetDeck(code : String) -> ChordsDeck:
	var deckFitered = Decks.filter(func(d : ChordsDeck): return d.Code == code)
	if len(deckFitered) > 0:
		return deckFitered[0]
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
		newNote.MidiCode = note["MidiCode"]
		newNote.Code = note["Code"]
		newNote.Octave = note["Octave"]
		newNote.Hue = note["Hue"]
		newNote.Saturation = note["Saturation"]
		newNote.Value = note["Value"]
		Notes.append(newNote)
		
func __LoadChords():
	var chordsFile = FileAccess.open("res://Data/Chords.json", FileAccess.READ)
	var chordsDict = JSON.parse_string(chordsFile.get_as_text())
	chordsFile.close()	
	Chords = []
	for chord in chordsDict["Chords"]:
		var newChord = Chord.new()
		newChord.Code = chord["Code"]
		newChord.Name = chord["Name"]	
		for note in chord["Notes"]:
			var noteEvent = GetNoteByName(str(note), BASE_OCTAVE)
			newChord.Notes.append(noteEvent)
		Chords.append(newChord)
		
func __LoadDecks():
	var decksFile = FileAccess.open("res://Data/ChordsDecks.json", FileAccess.READ)
	var decksDict = JSON.parse_string(decksFile.get_as_text())
	decksFile.close()	
	Decks = []
	for deck in decksDict["Decks"]:
		var newChordsDeck = ChordsDeck.new()
		newChordsDeck.Code = deck["Code"]
		newChordsDeck.Name = deck["Name"]			
		newChordsDeck.TexturePath = deck["TexturePath"]	
		newChordsDeck.Tone = deck["Tone"]	
		newChordsDeck.Level = deck["Level"]	
		newChordsDeck.Name = deck["Name"]	
		for chordCode in deck["Chords"]:
			var chord = GetChordByCode(str(chordCode))
			newChordsDeck.Chords.append(chord)
		Decks.append(newChordsDeck)
		
		
	
	
