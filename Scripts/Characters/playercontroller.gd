extends CharacterBody2D

@export var playerId: int = 1
@export var playerSpriteId: int = 1
@export var speed: float = 150
@export var rotateSpeed: float = 2
@export var bulletTimer: float = 1
@export var playerSprites = []

const bulletPre = preload ("res://Nodes/Characters/bullet.tscn")
@onready var spr = $Sprite2D
var canShoot: bool = true

func _ready():
	spr.texture = playerSprites[playerSpriteId-1][0]

func _physics_process(delta):
	velocity = Vector2.ZERO

	characterInput(delta)
	move_and_slide()

func shoot():
	var main = get_tree().current_scene
	var bullet = bulletPre.instantiate()
	var bulletSpr = bullet.get_child(0)
	var cannon = get_node("Cannon")
	main.add_child(bullet)
	bulletSpr.texture = playerSprites[playerSpriteId-1][1]
	bullet.transform = cannon.global_transform

func characterInput(delta):
	# if playerId == 1:
	if Input.is_action_pressed("p"+str(playerId)+"_up"):
		velocity = Vector2(0, -speed).rotated(rotation)
	if Input.is_action_pressed("p"+str(playerId)+"_down"):
		velocity = Vector2(0, speed).rotated(rotation)
	if Input.is_action_pressed("p"+str(playerId)+"_right"):
		rotation += rotateSpeed * delta
	if Input.is_action_pressed("p"+str(playerId)+"_left"):
		rotation -= rotateSpeed * delta
	if Input.is_action_pressed("p"+str(playerId)+"_shoot") and canShoot:
		shoot()
		canShoot = false
		await get_tree().create_timer(bulletTimer).timeout
		canShoot = true
