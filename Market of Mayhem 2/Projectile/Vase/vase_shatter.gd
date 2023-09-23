extends GPUParticles3D

func _ready() -> void:
	emitting = true


func _physics_process(_delta: float) -> void:
	if emitting == false:
		queue_free()
