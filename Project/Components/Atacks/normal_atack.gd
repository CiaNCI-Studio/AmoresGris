class_name NormalAtack extends AtackBase

@export var RootNote : NoteEvent
@export var ThirdNote : NoteEvent
@export var FifthNote : NoteEvent

@onready var root: Sprite2D = $Root
@onready var third: Sprite2D = $Third
@onready var fifth: Sprite2D = $Fifth
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var base_trail: GPUParticles2D = $Root/BaseTrail
@onready var third_trail: GPUParticles2D = $Third/ThirdTrail
@onready var fifht_trail: GPUParticles2D = $Fifth/FifhtTrail
@onready var point_light_2d: PointLight2D = $PointLight2D

var active = true

func _ready() -> void:	
	animation_player.play("Spin")
	if RootNote:
		root.modulate = RootNote.NoteColor
	else:
		root.visible = false	
	if ThirdNote:
		third.modulate = ThirdNote.NoteColor
	else:
		third.visible = false		
	if FifthNote:
		fifth.modulate = FifthNote.NoteColor
	else:
		fifth.visible = false

func _on_contact_area_body_entered(body: Node2D) -> void:
	if not active:
		return
	if body.is_in_group("player") or body == self or body.is_in_group("atack"):
		return
	if body.is_in_group("enemy"):
		pass
	Explode()


func Explode():
	if not active:
		return
	var instance = load("res://Components/Atacks/Impact.tscn").instantiate() as Impact
	instance.RootNote = RootNote
	instance.ThirdNote = ThirdNote
	instance.FifthNote = ThirdNote
	add_sibling(instance)
	instance.global_position = global_position
	if linear_velocity.x > 0:
		instance.scale = -instance.scale
	active = false
	root.self_modulate.a = 0
	third.self_modulate.a = 0
	fifth.self_modulate.a = 0
	base_trail.emitting = false
	third_trail.emitting = false
	fifht_trail.emitting = false
	point_light_2d.enabled = false
	collision_layer = 0
	await get_tree().create_timer(5).timeout
	queue_free()
