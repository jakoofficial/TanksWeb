extends CharacterBody2D

@export var playerId: int = 1
@export var playerSpriteId: int = 1
@export var speed: float = 150
@export var rotateSpeed: float = 2
@export var bulletTimer: float = 1
@export var playerSprites = []
@export var playerName: String = "Test"

const bulletPre = preload ("res://Nodes/Characters/bullet.tscn")
@onready var spr = $Sprite2D
var canShoot: bool = true

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	playerName = name
	spr.texture = playerSprites[playerSpriteId-1][0]

func _process(delta):
	$Label.text = playerName

func _physics_process(delta):
	velocity = Vector2.ZERO

	if is_multiplayer_authority():
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
	if Input.is_action_pressed("p1_up"):
		velocity = Vector2(0, -speed).rotated(rotation)
	if Input.is_action_pressed("p1_down"):
		velocity = Vector2(0, speed).rotated(rotation)
	if Input.is_action_pressed("p1_right"):
		rotation += rotateSpeed * delta
	if Input.is_action_pressed("p1_left"):
		rotation -= rotateSpeed * delta

	# var dir = Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down")
	# velocity = dir * speed
	if Input.is_action_pressed("p"+str(playerId)+"_shoot") and canShoot:
		shoot()
		canShoot = false
		await get_tree().create_timer(bulletTimer).timeout
		canShoot = true
