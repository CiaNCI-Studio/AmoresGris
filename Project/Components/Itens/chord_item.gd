class_name ChordItem extends ItemBase

@onready var item_label: Label = $Sprite/ItemLabel

func _ready() -> void:
	Type = ItemTypes.ChordItem
	var cardText = tr(Text).replace(" ", "\n")
	item_label.text = tr(cardText)
