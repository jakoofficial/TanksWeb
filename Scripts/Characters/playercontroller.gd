extends CharacterBody2D

@export var playerId: int = 1
@export var playerSpriteId: int = 1
@export var speed: float = 150
@export var rotateSpeed: float = 2
@export var bulletTimer: float = 1
@export var playerSprites = []
@export var playerName: String = "Test"
signal player_entered
const bulletPre = preload ("res://Nodes/Characters/bullet.tscn")
@onready var spr = $Sprite2D
var canShoot: bool = true

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		playerName = get_tree().get_first_node_in_group("test").text
		#player_entered.emit(self)

func _ready():
	spr.texture = playerSprites[playerSpriteId-1][0]

func _process(delta):
	$Node2D/Label.text = playerName
	$Node2D.global_rotation = 0
	$Node2D.global_position.y = global_position.y - 48
	$Node2D.global_position.x = global_position.x

func _physics_process(delta):
	velocity = Vector2.ZERO

	if is_multiplayer_authority():
		characterInput(delta)
	move_and_slide()

func shoot():
	var cannon = get_node("Cannon")
	spawnBullet.rpc(position, cannon.global_transform)
	#bulletSpr.texture = playerSprites[playerSpriteId-1][1]

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
	if Input.is_action_pressed("p1_shoot") and canShoot:
		shoot()
		canShoot = false
		await get_tree().create_timer(bulletTimer).timeout
		canShoot = true

@rpc("call_local")
func spawnBullet(pos:Vector2, forward:Transform2D):
	var main = get_tree().current_scene
	var bullet = bulletPre.instantiate()
	var bulletSpr = bullet.get_child(0)
	main.add_child(bullet)
	bullet.transform = forward
