extends CharacterBody3D

@export var velocidad_avance: float = 10.0
@export var velocidad_lateral: float = 8.0
# La zona muerta evita que el personaje se mueva a los lados si tocas muy cerca del centro
@export var zona_muerta_centro: float = 0.15 

var tocando_pantalla: bool = false
var posicion_toque: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	# Detectar cuando el dedo toca la pantalla
	if event is InputEventScreenTouch:
		if event.pressed:
			tocando_pantalla = true
			posicion_toque = event.position
		else:
			tocando_pantalla = false
			
	# Actualizar la posición si el dedo se arrastra por la pantalla
	elif event is InputEventScreenDrag:
		posicion_toque = event.position

func _physics_process(delta: float) -> void:
	if tocando_pantalla:
		# 1. Avanzar hacia adelante (en Godot 3D, adelante suele ser el eje -Z)
		velocity.z = -velocidad_avance
		
		# 2. Calcular el movimiento lateral
		var ancho_pantalla = get_viewport().get_visible_rect().size.x
		var centro_x = ancho_pantalla / 2.0
		
		# Esto nos da un valor entre -1.0 (borde izquierdo) y 1.0 (borde derecho)
		var desvio_lateral = (posicion_toque.x - centro_x) / centro_x
		
		# 3. Aplicar el movimiento lateral si está fuera de la zona muerta
		if abs(desvio_lateral) > zona_muerta_centro:
			# Multiplicamos la velocidad por el desvío para que sea progresivo 
			# (más rápido cuanto más al borde toques)
			velocity.x = desvio_lateral * velocidad_lateral
		else:
			# Si toca en el centro, no se mueve a los lados
			velocity.x = move_toward(velocity.x, 0.0, velocidad_lateral)
			
	else:
		# Si soltamos la pantalla, frenamos poco a poco al personaje
		velocity.z = move_toward(velocity.z, 0.0, velocidad_avance * delta * 5.0)
		velocity.x = move_toward(velocity.x, 0.0, velocidad_lateral * delta * 5.0)

	# Ejecutar el movimiento
	move_and_slide()
