extends Button

signal chooseColor

@export var tankColorId: int = 1
@export var tankIcon: Texture

func _ready():
	icon = tankIcon

func _on_pressed():
	emit_signal("chooseColor", tankColorId)
