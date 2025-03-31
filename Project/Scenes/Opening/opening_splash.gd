extends Node2D

@export var PARTICLE_COUNT : int = 400
@export var PARTICLE_PER_PROCESS : int = 1
@export var PARTICLE_SCENE : String = "res://Scenes/Opening/SplashParticle.tscn"
@export var TRANSITION_TIME : float = 0.5
@export var WAIT_TIME : float = 2.0
@export var BLACK_TRANSITION : float = 1.0
@export var NEXT_SCENE : String = "res://Scenes/Menus/MainMenu.tscn"

@onready var particles_layer: Node2D = $ParticlesLayer
@onready var points: Node2D = $Points
@onready var cianciLogo: Sprite2D = $Pivot/Logo/CiaNci
@onready var logo_collision: CollisionPolygon2D = $Pivot/Logo/LogoCollision
@onready var bucket_colision: CollisionPolygon2D = $Pivot/Bucket/BucketColision
@onready var cianci_text: Sprite2D = $Pivot/Logo/CianCiText
@onready var cianci_bucket: Sprite2D = $Pivot/Bucket/CiaNciBucket
@onready var black_screen: ColorRect = $Front/Control/BlackScreen
@onready var pivot: Node2D = $Pivot
@onready var skip_button: Button = $Front/Control/SkipButton

var Particles : Array[RigidBody2D] = []
var particleCount : int = 0
var transitionTimer : float = 0
var stage : int = 0

func _ready() -> void:
	TranslationServer.set_locale(GameOptions.CurrentLanguage)
	skip_button.grab_focus()

func _process(delta: float) -> void:
	
	match stage:
		0:
			if Input.is_action_pressed("left"):
				if pivot.rotation <= deg_to_rad(45):
					pivot.rotation += delta
			if Input.is_action_pressed("right"):
				if pivot.rotation >= deg_to_rad(-45):
					pivot.rotation -= delta
			if Input.is_action_just_pressed("start"):
				particleCount = PARTICLE_COUNT
				return
			
			for i in range(PARTICLE_PER_PROCESS):
				var particle = load(PARTICLE_SCENE).instantiate() as RigidBody2D
				var point = points.get_children().pick_random() as Marker2D
				particles_layer.add_child(particle)
				particle.global_position = point.global_position
				Particles.append(particle)
				particleCount += 1
				if particleCount >= PARTICLE_COUNT:
					transitionTimer = TRANSITION_TIME
					stage += 1
		1:
			transitionTimer -= delta
			if transitionTimer <= 0:
				stage += 1			
		2:
			stage += 1		
			create_tween().tween_property(cianci_bucket, "modulate", Color.TRANSPARENT, TRANSITION_TIME)
			create_tween().tween_property(cianciLogo, "modulate", Color.BLACK, TRANSITION_TIME)
			create_tween().tween_property(cianci_text, "modulate", Color.BLACK, TRANSITION_TIME)
			create_tween().tween_property(pivot, "rotation", 0, TRANSITION_TIME)
			await get_tree().create_timer(TRANSITION_TIME).timeout
			bucket_colision.disabled = true
			logo_collision.disabled = true
			await get_tree().create_timer(WAIT_TIME).timeout
			create_tween().tween_property(black_screen, "modulate:a", 1, BLACK_TRANSITION)
			create_tween().tween_property(skip_button, "modulate:a", 0, BLACK_TRANSITION)
			await get_tree().create_timer(BLACK_TRANSITION).timeout
			get_tree().change_scene_to_file(NEXT_SCENE)
			
func _on_skip_button_pressed() -> void:
	stage = 2
