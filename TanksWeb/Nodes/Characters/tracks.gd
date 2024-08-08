extends Sprite2D

@export var fadeTimer: float = 0.5
@export var fadeAmount: float = 0.2
var canFade: bool = true

func _physics_process(delta):
	modulate.a -= fadeAmount * delta
		
	if (modulate.a <= 0.1):
		queue_free()
