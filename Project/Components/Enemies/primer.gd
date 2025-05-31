class_name Primer extends CharacterBody2D

signal FinishedCombat

@export var Active : bool = true
@onready var orbs_animation: AnimationPlayer = $OrbsAnimation
@onready var orbs_pivot: Node2D = $OrbsPivot
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var bt_player: BTPlayer = $BTPlayer
@export var Speed : float = 100.0
@onready var ShotsLeft : Array[Marker2D] = [$ShootPoints/Shot1, $ShootPoints/Shot2, $ShootPoints/Shot3]
@onready var ShotsRight : Array[Marker2D] = [$ShootPoints/Shot4, $ShootPoints/Shot5, $ShootPoints/Shot6]
@export var Hp : int = 100
@export var MaxHp : int = 100
@onready var hp_bar: ProgressBar = $CanvasLayer/Control/HpBar
@onready var fader: Fader = $CanvasLayer/Control/Fader

var movingValue : float = false
var movingTimer : float =  0

func _ready() -> void:
	animation_tree.set("parameters/Mode/blend_amount", -1.0)
	hp_bar.value = 100
	Hp = MaxHp

func _physics_process(delta: float) -> void:	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if not Active:
		return
		
	if movingTimer > 0:
		movingTimer -= delta
		velocity.x = lerp(velocity.x, movingValue, 0.2)
	elif velocity.x != 0:
		movingValue = 0
		velocity.x = lerp(velocity.x, 0.0, 0.2)
			
	move_and_slide()

func Move():
	if not Active:
		return
	movingValue = randi_range(-1, 1) * Speed
	movingTimer = randf_range(3, 5)
	
func StartCombat():
	var tween = create_tween()
	tween.tween_property(animation_tree, "parameters/Mode/blend_amount", 0.0, 2.0)
	await tween.finished	
	orbs_animation.play("Rotate")
	bt_player.active = true	
	fader.FadeIn(1.0)

func FinishCombat():	
	Active = false
	bt_player.active = false
	var tween1 = create_tween()
	tween1.tween_property(animation_tree, "parameters/Mode/blend_amount", 1.0, 2.0)
	tween1.tween_property(self, "modulate", Color.WHITE, 2.0)
	await tween1.finished	
	var tween2 = create_tween()
	tween2.tween_property(orbs_pivot, "global_scale", Vector2(0.0, 0.0), 1.0)
	await tween2.finished
	collision_layer = 0
	FinishedCombat.emit()
	
func ShotAtack():
	orbs_animation.stop()
	await get_tree().create_timer(1).timeout
	for point in ShotsLeft:
		var instance = load("res://Components/Atacks/EnemyAtack.tscn").instantiate() as EnemyAtack
		get_parent().add_child(instance)
		instance.global_position = point.global_position
		instance.apply_impulse(Vector2.LEFT * 500)
	for point in ShotsRight:
		var instance = load("res://Components/Atacks/EnemyAtack.tscn").instantiate() as EnemyAtack
		get_parent().add_child(instance)
		instance.global_position = point.global_position
		instance.apply_impulse(Vector2.RIGHT * 500)	
	await get_tree().create_timer(1).timeout
	orbs_animation.play("Rotate")
	
func ExpandAtack() -> bool:
	var tween1 = create_tween()
	tween1.tween_property(orbs_pivot, "global_scale", Vector2(10.0, 10.0), 3.0)
	await tween1.finished
	var tween2 = create_tween()
	tween2.tween_property(orbs_pivot, "global_scale", Vector2(1.0, 1.0), 3.0)
	await tween2.finished
	return true

func TakeDamage(value : int):
	if not Active:
		return
	Hp -= value	
	hp_bar.value = remap(Hp, 0, MaxHp, 0 , 100)
	if Hp <= 0:
		Active = false
		FinishCombat()				
		
		
func _on_contact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and Active:
		(body as Player).TakeDamage(20)
		
func _on_contact_area_prime_body_entered(body: Node2D) -> void:
	if Active:
		if body.is_in_group("atack"):
			TakeDamage((body as AtackBase).Power)
