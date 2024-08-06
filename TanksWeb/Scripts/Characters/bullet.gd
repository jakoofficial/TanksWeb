extends Area2D

@export var spd : int = 10
@onready var explosionPre = preload("res://Nodes/Effects/explosion.tscn") 

func _physics_process(delta):
	position += Vector2.from_angle(transform.get_rotation()-PI/2) * (spd * 10) * delta

func _on_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		explode()
		#body.hit()
		queue_free()
	if body.is_in_group("Statics"):
		explode()
		queue_free()

func explode():
	var explosion = explosionPre.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.transform = self.global_transform
	print("hel")


func _on_visible_on_screen_notifier_2d_screen_exited():
	#explode()
	queue_free()
