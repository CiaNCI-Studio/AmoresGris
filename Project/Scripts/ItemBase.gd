class_name ItemBase extends StaticBody2D

enum ItemTypes {
	None,
	ChordItem,
	ScoreItem
}

@export var Type : ItemTypes = ItemTypes.None
@export var Value : String = ""
@export var Text : String = ""
