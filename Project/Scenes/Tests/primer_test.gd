extends Node2D

@onready var player: Player = $Player
@onready var primer: Primer = $Primer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.EnableAtack()
	player.EnableDash()
	player.CurrentDecks = NotesColorService.Decks
	player.SelectDeck("C")
	player.AvailibleChords = [1,2,3,4,5,6,7]
	player.UpddateHud()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):		
		primer.StartCombat()
