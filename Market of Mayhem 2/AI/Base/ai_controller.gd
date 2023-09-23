class_name AIController
extends Node3D

@onready var detection_area: Area3D = $DetectionArea
@onready var nav_agent: NavigationAgent3D = $NavAgent
@onready var back_up_timer: Timer = $Timers/BackUpTimer
@onready var punch_think_timer: Timer = $Timers/PunchThinkTimer
@onready var fire_think_timer: Timer = $Timers/FireThinkTimer

var actor : Character = null
var actor_pos : Vector3 
var target : Character = null
var target_pos : Vector3
var direction : Vector2 = Vector2()
var wander_target : Vector3

var is_wandering : bool = true
var can_punch : bool = true
var can_fire : bool = true
var did_i_fire : bool = false
var is_target_in_punch_range : bool = false
var is_target_in_sights : bool = false
var is_using_ranged : bool = true

const MAX_CLOSENESS : float = 1.0
const RANGED_RADIUS : float = 5.0

signal request_action


func run(delta) -> void:
	actor_pos = actor.global_position
	if did_i_fire:
		did_i_fire = false
		request_action.emit("StopFire")
	handle_targetting()
	handle_movement()
	handle_attacking()
	DebugDraw.draw_gizmo(global_transform, Color(Color.WEB_PURPLE))



func handle_targetting() -> void:
	if not target:
		# Check whether a target is in sight. Wander if not.
		target = detection_area.get_new_target(actor_pos)
		if target:
			print("My target now " + str(target.name))
			# Do we need to reset wander_target?
			is_wandering = false
			return
		check_wander_target()
		return
	
	# Check current target and wander if not available
	if is_target_valid():
		if actor.get_health() < 40 and can_fire:
			is_using_ranged = true
		else:
			is_using_ranged = false
			
		target_pos = target.global_position

		nav_agent.set_target_position(target_pos)
	else:
		is_wandering = true


func handle_movement() -> void:
	if is_wandering:
		move_to_target()
		return
	
	var distance_to_target : float = (target_pos - actor_pos).length()
	is_target_in_sights = distance_to_target < RANGED_RADIUS 
	is_target_in_punch_range = distance_to_target < MAX_CLOSENESS 
#	print(str(is_target_in_punch_range) + " : " + str((target_pos - actor_pos).length()))
	
	if not back_up_timer.is_stopped():
		back_up()
		return
	
	move_to_target()


func handle_attacking() -> void:
	if punch_think_timer.is_stopped():
		if is_target_in_punch_range and can_punch:
			punch_think_timer.wait_time = randf_range(0.1, 0.2)
			punch_think_timer.start()
			
	
	if is_target_in_sights and can_fire:
		var distance_to_target : float = (target_pos - actor_pos).length()
		if distance_to_target < RANGED_RADIUS and distance_to_target > MAX_CLOSENESS + 1.0:
			request_action.emit("Fire")
			did_i_fire = true

###############################################################################################################

func move_to_target() -> void:
	var vector_to_target : Vector3 = (nav_agent.get_next_path_position() - actor_pos)
	direction = Vector2(vector_to_target.x, vector_to_target.z).normalized()
	rotation.y = atan2(-direction.x, -direction.y)


func back_up() -> void:
	direction = Vector2(0, 1)
	var vector_to_opponent : Vector3 = target_pos - actor_pos
	vector_to_opponent.y = 0
	vector_to_opponent = vector_to_opponent.normalized()
	rotation.y = atan2(-vector_to_opponent.x, -vector_to_opponent.z)


func is_target_valid() -> bool:
	if target.is_dead:
		return false
	
	return true


func check_wander_target() -> void:
	if nav_agent.is_navigation_finished():
		while true:
			var target_range : Vector3 = Vector3(randf_range(-10.0, 10.0), 0, randf_range(-10.0, 10.0))
			var new_wander_target : Vector3 = actor_pos + target_range
			nav_agent.set_target_position(new_wander_target)
			if nav_agent.is_target_reachable():
				wander_target = new_wander_target
				break


func get_direction() -> Vector2:
	return direction


func reset_ai() -> void:
	target = null
	wander_target = actor.global_position



func initiate(new_actor):
	actor = new_actor
	
	detection_area.set_actor(actor)
	request_action.connect(Callable(actor, "request_action"))
	
	if actor is Florist:
		nav_agent.set_navigation_layer_value(2, true)
	elif actor is Produce:
		nav_agent.set_navigation_layer_value(3, true)
	elif actor is MeatDude:
		nav_agent.set_navigation_layer_value(4, true)
	elif actor is Freight:
		nav_agent.set_navigation_layer_value(5, true)
	elif actor is KitchenDude:
		nav_agent.set_navigation_layer_value(6, true)
	elif actor is Baker:
		nav_agent.set_navigation_layer_value(7, true)
	elif actor is Cashier:
		nav_agent.set_navigation_layer_value(8, true)
	
	# Because a target was already set for some reason?
	nav_agent.set_target_position(actor.spawn_point)



func _on_punch_think_timer_timeout() -> void:
	request_action.emit("Attack")
	back_up_timer.wait_time = 0.3
	back_up_timer.start()
