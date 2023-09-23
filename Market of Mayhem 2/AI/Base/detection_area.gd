extends Area3D

var actor : Character = null
var opponents_in_sight : Array = []


func get_new_target(actor_pos : Vector3) -> Character:
	if opponents_in_sight.size() == 0:
		return null
	
	var potential_target : Character = opponents_in_sight[0]
	var distance_to_target : float = (actor_pos - potential_target.global_position).length()
	
	# Find closest dude and return as new target
	for dude in opponents_in_sight:
		var distance_to_dude : float = (actor_pos - dude.global_position).length()
		if distance_to_dude < distance_to_target:
			potential_target = dude
			distance_to_target = distance_to_dude
	
	return potential_target


func is_dude_in_sight(dude : Character) -> bool:
	var actor_pos : Vector3 = actor.global_position # Any way we can get this one time per frame and pass it to funcs?
	var ray : RayCast3D = RayCast3D.new()
	add_child(ray)
	
	# Setup ray
	ray.global_position = actor_pos + Vector3(0, 2, 0)
	var vector_to_dude : Vector3 = dude.global_position - ray.global_position
	ray.target_position = vector_to_dude
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	ray.set_collision_mask_value(1, true)
	ray.set_collision_mask_value(2, true)
	
	ray.force_raycast_update()
	if ray.is_colliding():
		if ray.get_collider() is Character:
			ray.queue_free()
			return true
	
	ray.queue_free()
	return false


func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		if not is_dude_in_sight(body):
			return
		if body.get_team() != actor.get_team():
			if opponents_in_sight.has(body):
				print("Why is " + str(body.name) + " already in the array???")
			opponents_in_sight.push_back(body)


func _on_body_exited(body: Node3D) -> void:
	if body is Character:
		if body.get_team() == actor.get_team():
			return
		
		if opponents_in_sight.has(body):
			opponents_in_sight.erase(body)
#		else:
#			print("Why isn't " + str(body.name) + " in the fucking array???")


func set_actor(new_actor : Character) -> void:
	actor = new_actor
