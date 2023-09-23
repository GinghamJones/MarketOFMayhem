extends Camera3D


var move_speed : float = 9.0
var look_speed : float = 0.3
var mouse_delta : Vector2
var enabled : bool = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		rotation -= Vector3(mouse_delta.y, mouse_delta.x, 0) * look_speed * get_process_delta_time()


func _process(delta: float) -> void:
	if current == true:
		enabled = true
	else:
		enabled = false
	if !enabled:
		return
	
	var z_input : float = Input.get_action_strength("MoveForward") - Input.get_action_strength("MoveBack")
	var x_input : float = Input.get_action_strength("MoveLeft") - Input.get_action_strength("MoveRight")
	var y_input : float = Input.get_action_strength("Punch") - Input.get_action_strength("FireProjectile")
	
	global_position += ((-transform.basis.z * z_input) + (-transform.basis.x * x_input) + (transform.basis.y * y_input)) * move_speed * delta
#	global_position += global_position.lerp((transform.basis.z * move_speed * z_input * delta) + global_position, 0.1)
#	global_position += global_position.lerp((transform.basis.y * move_speed * y_input * delta) + global_position, 0.1)
#	global_position += global_position.lerp((transform.basis.x * move_speed * x_input * delta) + global_position, 0.1)
	
	
