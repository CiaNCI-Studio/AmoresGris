class_name EnemyBase extends CharacterBody2D

signal Deactivate

@export var Active : bool = true
@export var Hp : int = 10
@export var MaxHp : int = 10
@export var Damage : int = 10
@export var RecoverRate : int = 1
@export var Speed : float = 100.0
@export var AtackSpeed : float = 800.0
@export var AtackDistance : float = 200.0
@export var AtackYDistance : float = 50.0
@export var AtackTime : float = 0.5

var movingValue : float = false
var movingTimer : float =  0

func _physics_process(delta: float) -> void:
	# Add the gravity.
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
	
func IsPlayerInRange() -> int:
	if not Active:
		return 0
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D	
	var distance = global_position.distance_to(player.global_position)
	if abs(distance) <= AtackDistance:
		var direction = player.global_position.x - global_position.x 
		if direction > 0:
			return 1
		else:
			return -1		
	return 0
		
func TakeDamage(value : int):
	if not Active:
		return
	Hp -= value
	if Hp <= 0:
		Active = false
		Deactivate.emit()
		
