class_name EnemySmall extends EnemyBase

@onready var shadow_particles: GPUParticles2D = $ShadowParticles
@onready var dark_light: PointLight2D = $DarkLight
@onready var light: PointLight2D = $Light
@onready var bt_player: BTPlayer = $BTPlayer
@onready var hit_area: Area2D = $HitArea
@onready var recover_timer: Timer = $RecoverTimer
@onready var leaves_particles: GPUParticles2D = $LeavesParticles
@onready var heart_particles: GPUParticles2D = $HeartParticles
@onready var animation_tree: AnimationTree = $EnemySmallAnimation/AnimationTree

var recoverPlayer : Player = null

func _process(delta: float) -> void:
	if not Active:
		CheckRecover()
		if recoverPlayer:
			heart_particles.emitting = true
		else:
			heart_particles.emitting = false		
		return
	var speed = velocity.x
	var animationSpeed = remap(speed, -400.0, 400.0, -1.0, 1.0)
	animation_tree.set("parameters/Speed/blend_position", animationSpeed)

func Atack() -> bool:
	if not Active:
		return false
	var direction = IsPlayerInRange()	
	if direction != 0:		
		if direction > 0:
			AntecipationRight()
			await get_tree().create_timer(1).timeout
			AtackRight()
			movingValue = AtackSpeed
		else:
			AntecipationLeft()
			await get_tree().create_timer(1).timeout
			AtackLeft()		
			movingValue = -AtackSpeed
		movingTimer = AtackTime
		return true
	return false

func HitEffect():
	if not Active:
		return false
	dark_light.energy = lerp(dark_light.energy, remap(Hp, 0, MaxHp, 0, 1), 0.5) 
	for i in range(3):
		light.enabled = true
		modulate = Color.WHITE
		await get_tree().create_timer(0.05).timeout
		light.enabled = false
		modulate = Color.BLACK
		await get_tree().create_timer(0.05).timeout

func _on_deactivate() -> void:		
	dark_light.enabled = false
	light.enabled = true
	modulate = Color.WHITE
	shadow_particles.emitting = false
	leaves_particles.emitting = true
	bt_player.active = false
	recover_timer.start()
	animation_tree.set("parameters/Inactive/blend_amount", lerp(0, 1, 0.5))
	

func CheckRecover():
	var overlaping = hit_area.get_overlapping_bodies()
	var players = overlaping.filter(func(body : Node2D) : return body.is_in_group("player"))
	if len(players) > 0:
		recoverPlayer = players[0]
	else:
		recoverPlayer = null

func _on_hit_area_body_entered(body: Node2D) -> void: 
	if Active:
		if body.is_in_group("atack"):
			TakeDamage((body as AtackBase).Power)
			HitEffect()
		if body.is_in_group("player"):
			(body as Player).TakeDamage(Damage)

func _on_recover_timer_timeout() -> void:
	if recoverPlayer:
		recoverPlayer.Recover(RecoverRate)
		
func AtackLeft():
	animation_tree.set("parameters/AtackLeft/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func AtackRight():
	animation_tree.set("parameters/AtackRight/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func AntecipationLeft():
	animation_tree.set("parameters/AntecipationLeft/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func AntecipationRight():
	animation_tree.set("parameters/AntecipationRight/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
