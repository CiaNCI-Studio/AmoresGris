class_name EnemyBaseAtack extends EnemyAtack


var active = true
@onready var sprite: Sprite2D = $Sprite
@onready var trail: GPUParticles2D = $Trail


func _on_contact_area_body_entered(body: Node2D) -> void:
	if not Active:
		return
	if body.is_in_group("enemy") or body == self or body.is_in_group("enemyAtack"):
		return
	if body.is_in_group("player") and Active:
		(body as Player).TakeDamage(20)
			
	Explode()

func Explode():
	if not Active:
		return
	var instance = load("res://Components/Atacks/SimpleImpact.tscn").instantiate() as SimpleImpact	
	add_sibling(instance)
	instance.global_position = global_position
	if linear_velocity.x > 0:
		instance.scale = -instance.scale
	Active = false
	sprite.self_modulate.a = 0
	trail.emitting = false	
	collision_layer = 0
	await get_tree().create_timer(5).timeout
	queue_free()
