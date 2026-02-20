extends CharacterBody3D

@export_category("Movimiento Frontal")
@export var velocidad_maxima_avance: float = 15.0
@export var tiempo_aceleracion: float = 2.0 
@export var tiempo_frenado: float = 5.0 

@export_category("Movimiento Lateral")
@export var velocidad_lateral: float = 8.0
@export var zona_muerta_centro: float = 0.15

@export_category("Efectos Visuales")
## Arrastra aquí el nodo de la malla (MeshInstance3D) del personaje
@export var modelo_visual: Node3D 
## Cuántos grados se inclinará hacia los lados
@export var inclinacion_maxima: float = 15.0 
## Qué tan rápido reacciona la inclinación (suavizado)
@export var suavizado_inclinacion: float = 5.0

var tocando_pantalla: bool = false
var posicion_toque: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			tocando_pantalla = true
			posicion_toque = event.position
		else:
			tocando_pantalla = false
	elif event is InputEventScreenDrag:
		posicion_toque = event.position

func _physics_process(delta: float) -> void:
	var tasa_aceleracion = velocidad_maxima_avance / tiempo_aceleracion if tiempo_aceleracion > 0 else 9999.0
	var tasa_frenado = velocidad_maxima_avance / tiempo_frenado if tiempo_frenado > 0 else 9999.0
	
	if tocando_pantalla:
		velocity.z = move_toward(velocity.z, -velocidad_maxima_avance, tasa_aceleracion * delta)
		
		var ancho_pantalla = get_viewport().get_visible_rect().size.x
		var centro_x = ancho_pantalla / 2.0
		var desvio_lateral = (posicion_toque.x - centro_x) / centro_x
		
		if abs(desvio_lateral) > zona_muerta_centro:
			velocity.x = desvio_lateral * velocidad_lateral
		else:
			velocity.x = move_toward(velocity.x, 0.0, velocidad_lateral * delta * 10.0)
	else:
		velocity.z = move_toward(velocity.z, 0.0, tasa_frenado * delta)
		velocity.x = move_toward(velocity.x, 0.0, velocidad_lateral * delta * 10.0)

	move_and_slide()
	
	# === LÓGICA DE INCLINACIÓN VISUAL ===
	if modelo_visual:
		# 1. Calculamos la rotación deseada en base a la velocidad lateral actual
		# Usamos deg_to_rad porque Godot trabaja las rotaciones en radianes
		var objetivo_z = -velocity.x / velocidad_lateral * deg_to_rad(inclinacion_maxima)
		
		# 2. Aplicamos la rotación suavemente con lerp (interpolación lineal)
		modelo_visual.rotation.z = lerp_angle(modelo_visual.rotation.z, objetivo_z, suavizado_inclinacion * delta)
		
		# Extra: Pequeña inclinación hacia adelante al acelerar
		var objetivo_x = (velocity.z / velocidad_maxima_avance) * deg_to_rad(-5.0)
		modelo_visual.rotation.x = lerp_angle(modelo_visual.rotation.x, objetivo_x, suavizado_inclinacion * delta)
