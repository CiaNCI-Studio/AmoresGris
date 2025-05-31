extends BaseControler2D
class_name SideScrollingControler2D

signal sprint_start
signal sprint_end
signal jump_start
signal jump_cancel
signal jump_end
signal hit_wall
signal leave_wall
signal hit_hang
signal leave_hang
signal dash_start
signal dash_end
signal dash_recovery(time : float)

@export_category("Camera")
@export var Handle_Camera : bool = true
@export var Camera_Smooth_Distance : float = 1
@export var Camera_Smooth_Speed : float = 5
@export var Camera_LookAt_Player: bool = true
@export var Camera_Lock_Y_Rotation: bool = true
@export var Camera_Max_Boundary: Vector2 = Vector2.ZERO
@export var Camera_Min_Boundary: Vector2 = Vector2.ZERO
@export var camera_zoom : Vector2 = Vector2(1, 1)
@export var Horizontal_Offset : float = 0
@export var Vertical_Offset : float = 0
@export var Custom_Camera : Camera2D

@export_category("Jump")
@export var Can_Jump : bool = true
@export var Variable_Jump : bool = true
@export var Jump_Height = 100.0
@export var Jump_Time_To_Peak = 0.4
@export var Jump_Time_To_Descend = 0.2
@export var Coyote_Time = 0.2
@export var Jump_Buffer_Time = 0.2

@export_category("Wall")
@export var HangHighPointRayCast : RayCast2D
@export var HangLowPointRayCast : RayCast2D
@export var WallIgnoreGroups : Array[String] = []


@export_category("Dash")
@export var CanDash : bool = true
@export var CanCancelDash : bool = true
@export var DashSpeed : float = 2000
@export var DashTime : float = 0.2
@export var DashRecoverTime : float = 2.0


@onready var jump_velocity = (2.0 * Jump_Height) / Jump_Time_To_Peak
@onready var jump_gravity = (-2.0 * Jump_Height) / (Jump_Time_To_Peak * Jump_Time_To_Peak)
@onready var fall_gravity = (-2.0 * Jump_Height) / (Jump_Time_To_Descend * Jump_Time_To_Descend)

var pivot : Node2D 
var camera : Camera2D 
var camera_rest_position : Vector2
var use_pivot = true
var on_hang : bool = false
var lastXDirection : float = 0
var dashTimer : float = 0
var dashRecoverTimer : float = 0
var dashing : bool = false
var dashRecover : bool = true

func _ready() -> void:
	if Handle_Camera:
		if Custom_Camera:
			camera = Custom_Camera
			use_pivot = false
		else:
			pivot = Node2D.new()
			add_child(pivot)
			pivot.position.x = Horizontal_Offset
			pivot.position.y = Vertical_Offset	
			camera = Camera2D.new()		
			pivot.add_child(camera)	
			camera.zoom = camera_zoom
			use_pivot = true
		
				
	toggle_active(Active)

func _physics_process(delta: float) -> void:
	if not Active:
		return
	
	HandleWall()
	handle_gravity(delta)
	HandleJump(delta)	
	HandleDash(delta)
		
	var direction = get_direction()
	var currentSpeed = get_speed()
			
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * currentSpeed, Acceleration * delta)
		lastXDirection = direction.x
		if Handle_Camera:
			if use_pivot:		
				if Camera_Smooth_Distance and abs(pivot.position.x) < Camera_Smooth_Distance:	
					pivot.position.x = move_toward(pivot.position.x, direction.x * currentSpeed * -1, Camera_Smooth_Speed * delta)
			else:
				if Camera_Smooth_Distance and abs(camera.position.x) < Camera_Smooth_Distance:	
					camera.position.x = move_toward(camera.position.x, direction.x * currentSpeed * -1, Camera_Smooth_Speed * delta)
	else:		
		velocity.x = move_toward(velocity.x, 0, Deacceleration * delta)		
		if Camera_Smooth_Distance and Handle_Camera:		
			if use_pivot:		
				pivot.position.x = move_toward(pivot.position.x, Horizontal_Offset, Camera_Smooth_Speed * delta)
			else:
				camera.position.x = move_toward(camera.position.x, Horizontal_Offset, Camera_Smooth_Speed * delta)
					
	if Handle_Camera:
		if Camera_LookAt_Player:
			camera.look_at(parent.global_position)		
		if Camera_Max_Boundary and Camera_Min_Boundary:
			if use_pivot:	
				if pivot.global_position.x > Camera_Max_Boundary.x and Camera_Max_Boundary.x != 0:
					pivot.global_position.x = Camera_Max_Boundary.x
				elif pivot.global_position.x < Camera_Min_Boundary.x and Camera_Min_Boundary.x != 0:
					pivot.global_position.x = Camera_Min_Boundary.x
				if pivot.global_position.y > Camera_Max_Boundary.y and Camera_Max_Boundary.y != 0:
					pivot.global_position.y = Camera_Max_Boundary.y
				elif pivot.global_position.y < Camera_Min_Boundary.y and Camera_Min_Boundary.y != 0:
					pivot.global_position.y = Camera_Min_Boundary.y										
			else:
				if camera.global_position.x > Camera_Max_Boundary.x and Camera_Max_Boundary.x != 0:
					camera.global_position.x = Camera_Max_Boundary.x
				elif camera.global_position.x < Camera_Min_Boundary.x and Camera_Min_Boundary.x != 0:
					camera.global_position.x = Camera_Min_Boundary.x
				if camera.global_position.y > Camera_Max_Boundary.y and Camera_Max_Boundary.y != 0:
					camera.global_position.y = Camera_Max_Boundary.y
				elif camera.global_position.y < Camera_Min_Boundary.y and Camera_Min_Boundary.y != 0:
					camera.global_position.y = Camera_Min_Boundary.y				
	
	move()


func get_gravity() -> Vector2:
	if Can_Jump:
		return Vector2(0, jump_gravity if velocity.y < 0.0 else fall_gravity)
	else:
		return parent.get_gravity()

func handle_gravity(delta : float):	
	if dashing:
		velocity.y = 0
	elif Handle_Gravity and not OnFloorOrHang():
		velocity += (get_gravity() * delta) * -1
	else:
		velocity.y = 0

func HandleJump(delta : float) -> void:
	
	if not Can_Jump or not Active or not InputEnabled:
		return			
		
	if OnFloorOrHang():
		coyote_timer = Coyote_Time;
		if jumping:
			emit_signal("jump_end")
		jumping = false
	elif coyote_timer > 0: 
		coyote_timer -= delta
	else:
		coyote_timer = 0 
		
	if jump_buffer_timer > 0: 
		jump_buffer_timer -= delta
	else:
		jump_buffer_timer = 0 
	
	var do_jump = false
		
	if Input.is_action_just_pressed(Input_Jump) and coyote_timer > 0 and not jumping:
		do_jump = true
	elif Input.is_action_just_pressed(Input_Jump) and not OnFloorOrHang() and Jump_Buffer_Time > 0:
		jump_buffer_timer = Jump_Buffer_Time
	elif Input.is_action_just_pressed(Input_Jump) and OnFloorOrHang() and Jump_Buffer_Time <= 0:
		do_jump = true
		
	if OnFloorOrHang() and jump_buffer_timer > 0 and not jumping:
		jump_buffer_timer = 0 
		do_jump = true			
	
	if do_jump:
		jumping = true
		emit_signal("jump_start")
		velocity.y = jump_velocity * -1
		
	if (parent.is_on_ceiling() and velocity.y < 0) :
		emit_signal("hit_ceiling")		
		velocity.y = 0
	if (Input.is_action_just_released(Input_Jump) and Variable_Jump and jumping) :
		emit_signal("jump_cancel")
		velocity.y = 0
		
func HandleDash(delta : float) -> void:
	if not CanDash or not Active or not InputEnabled:
		return
	
	if not dashRecover and not dashing:
		dashRecoverTimer -= delta
		dash_recovery.emit(dashRecoverTimer)
		if dashRecoverTimer <= 0:
			dashRecover = true
	
	var cancel_dash = false	
		
	if dashing:
		dashTimer -= delta
		if dashTimer <= 0 or velocity.x == 0 or (Input.is_action_just_released("dash") and CanCancelDash):
			cancel_dash = true
		
	if cancel_dash:
		dashing = false
		dashRecover = false 
		dashTimer = 0
		dashRecoverTimer = DashRecoverTime
		velocity.x = 0
		dash_end.emit()
		return
				
	if Input.is_action_just_pressed(Input_Dash) and not dashing and dashRecover:
		dashing = true
		dashRecover = false
		dashTimer = DashTime
		dash_start.emit()		
		if lastXDirection >= 0:			
			velocity.x = DashSpeed
		else:
			velocity.x = -DashSpeed
		


func toggle_active(state : bool):
	Active = state
	if Handle_Camera:
		if state:		
			camera.make_current()
		else:		
			camera.clear_current()
	
func OnFloorOrHang():
	return (on_hang and __CheckDirectionHold()) or parent.is_on_floor()
	
func HandleWall():
	if not InputEnabled:
		return
	if  HangHighPointRayCast and HangLowPointRayCast:		
		var hangHighColliding = __GetColiding(HangHighPointRayCast)
		var hangLowColliding = __GetColiding(HangLowPointRayCast)
		var hangColliding = hangLowColliding and not hangHighColliding
		
		if on_hang and not hangColliding:
			on_hang = false
			leave_hang.emit()
			print_debug("leave Hang")
		elif hangColliding and not on_hang and velocity.y > 0:
			on_hang = true
			hit_hang.emit()
			print_debug("Hit Hang")			

func __CheckDirectionHold() -> bool:
	if Input.is_action_pressed(Input_Right) and lastXDirection > 0:
		return true	
	if Input.is_action_pressed(Input_Left) and lastXDirection < 0:
		return true		
	return false

func __GetColiding(rayCast : RayCast2D) -> bool:	
	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		if WallIgnoreGroups.any(func(ignore : String) : return (collider as Node).is_in_group(ignore)):
			return false
		return true
	return false
