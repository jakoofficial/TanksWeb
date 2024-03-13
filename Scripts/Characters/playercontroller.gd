extends CharacterBody2D

signal player_entered
signal set_player_color

@export var playerId: int = 1
@export var playerSpriteId: int = 1
@export var speed: float = 150
@export var rotateSpeed: float = 2
@export var bulletTimer: float = 1
@export var playerSprites = []
@export var playerName: String = "Test"
@onready var spr = $"Sprite2D"

const bulletPre = preload ("res://Nodes/Characters/bullet.tscn")
var canShoot: bool = true
var playerTexture: Texture

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		playerName = get_tree().get_first_node_in_group("test").text
		playerSpriteId = get_tree().current_scene.playerColorId
		print(playerSpriteId)
		#changeColor.rpc(name.to_int(), playerSpriteId)
		#playerTexture = playerSprites[playerSpriteId-1][0]
		#print($"Sprite2D")
		#player_entered.emit(self)

func _ready():
	#spr.texture = playerSprites[playerSpriteId-1][0]
	changeColor(name.to_int(), playerSpriteId)

func _process(delta):
	#spr.texture = playerTexture
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
	bulletSpr.texture = playerSprites[playerSpriteId-1][1]
	main.add_child(bullet)
	bullet.transform = forward

#@rpc("call_local")
func changeColor(clientId, colorId):
	await get_tree().create_timer(0.05).timeout
	#var child = get_tree().current_scene.find_child(str(clientId))
	#var child = get_tree().current_scene.find_child("GuiMenu")
	$Sprite2D.texture = playerSprites[playerSpriteId-1][0]
