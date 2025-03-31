extends CharacterBody3D
class_name Player

@export var Hp : int = 100

@onready var third_person_controler_3d: ThirdPersonControler3D = $ThirdPersonControler3D

func _physics_process(delta: float) -> void:
	pass
