class_name PlayerController
extends Node3D

var mouse_delta : Vector2 = Vector2.ZERO

@onready var hud : HUD = $HUD
@onready var raycast : RayCast3D = $RayCast3D

var look_speed : float = 0.3
const MAX_LOOK_ANGLE : int = 60
const MIN_LOOK_ANGLE : int = -60
const MAX_ZOOM: float = 5
const MIN_ZOOM : float = -1
var dodge_direction : Vector2 = Vector2.ZERO : get = get_dodge_direction

var controller_positioner : Node3D = null
var actor : Character = null
var target : Character = null
# Maybe I could figure out how to detect if player is fleeing??
var is_fleeing : bool = false
var can_fire : bool = true
var can_punch : bool = true

signal request_action


func initiate(new_actor : Character):
	actor = new_actor
	controller_positioner = actor.get_node("ControllerPositioner")
	request_action.connect(Callable(actor, "request_action"))
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.initiate(actor)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.MOUSE_MODE_CAPTURED:
		mouse_delta = event.relative
	if event is InputEventJoypadMotion:
		mouse_delta = Vector2(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
	
	if event.is_action_pressed("Dodge"):
		request_action.emit("Dodge")

	if event.is_action_pressed("Punch"):
		request_action.emit("Attack")
	
	# Blocking is not a fully fleshed out feature. Could be nixed probably.
	if event.is_action_pressed("Block"):
		request_action.emit("Block")
#	if event.is_action_released("Block"):
#		emit_signal("unblock_me")

	if event.is_action_pressed("FireProjectile"):
		if is_projectile_available():
			request_action.emit("Fire")
		
	if event.is_action_released("FireProjectile"):
		request_action.emit("StopFire")
	
	# Special melee is not supported yet. Needs to be worked on.
	if event.is_action_pressed("SpecialMelee"):
		if is_special_available():
			request_action.emit("Special")
	
	# Remaining actions are Debug actions and should be removed for full release
	if event.is_action_pressed("StartRagdoll"):
		actor.die()
	
	if event.is_action_pressed("DebugCamera"):
		if $CameraSpringArm/Camera3D.current:
			get_tree().get_first_node_in_group("DebugCam").current = true
			$CameraSpringArm/Camera3D.current = false
		else:
			get_tree().get_first_node_in_group("DebugCam").current = false
			$CameraSpringArm/Camera3D.current = true
	
	if event.is_action_pressed("AICam"):
		if $CameraSpringArm/Camera3D.current:
			$CameraSpringArm/Camera3D.current = false
			get_tree().get_first_node_in_group("AICam").current = true
		else:
			get_tree().get_first_node_in_group("AICam").current = false
			$CameraSpringArm/Camera3D.current = true


func _process(delta: float) -> void:
	if actor:
		#Rotate camera
		rotation.x -= mouse_delta.y * look_speed * delta
		rotation.x = clamp(rotation.x, deg_to_rad(MIN_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))
		
		mouse_delta = Vector2()
	else:
		pass


func run(delta : float):
	# This is to display the health bar of whoever Player is looking at. Also was to be used for AI purposes: 
	# Initially planned to change AI behavior if they detected they were targetted so this would help determine 
	# if they're targetted by Player or not.
	if raycast.is_colliding():
			var dude = raycast.get_collider()
			if dude is Character:
				set_target(dude)
				hud.set_char_to_track(dude)
	
	DebugDraw.draw_gizmo(transform, Color(Color.BLUE))


func is_projectile_available() -> bool:
	if actor.get_ammo() <= 0 and not can_fire:
		return false
	
	return true


func is_special_available() -> bool:
	if actor.special_timer.is_stopped():
		return true
	
	return false


func get_direction() -> Vector2:
	var input_dir : Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	return input_dir


func handle_cursor():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func update_hud(ammo : int = -1, health : int = -1, lives_left : int = -1):
	if ammo >= 0:
		hud.update_ammo(ammo)
	
	if health >= 0:
		hud.update_health(health)
	
	if lives_left >= 0:
		hud.update_lives_left(lives_left)


func get_y_rotation() -> float:
	return mouse_delta.x * look_speed


func set_target(new_target : Character):
	target = new_target

func get_fleeing() -> bool:
	return is_fleeing


func get_dodge_direction() -> Vector2:
	return get_direction()
