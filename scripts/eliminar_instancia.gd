extends MeshInstance3D # O RigidBody3D, según tu objeto

func _on_timer_timeout():
	queue_free() # Se elimina solo al pasar X segundos

func _process(_delta):
	# Verificar si está detrás de la cámara activa
	var camera = get_viewport().get_camera_3d()
	if camera and camera.is_position_behind(global_position):
		queue_free()
