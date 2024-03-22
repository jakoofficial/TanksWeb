extends CharacterBody2D

signal player_entered
signal set_player_color
signal playerHit

@export var playerId: int = 1
@export var playerSpriteId: int = 1
@export var speed: float = 150
@export var rotateSpeed: float = 2
@export var bulletTimer: float = 1
@export var playerSprites = []
@export var playerName: String = "Test"
@export var canControl: bool = true
@export var spawnPos: Vector2

@onready var spr = $"Sprite2D"
@onready var muzzleflash = $Muzzleflash

const bulletPre = preload ("res://Nodes/Characters/bullet.tscn")
const trackPre = preload("res://Nodes/Characters/tracks.tscn")

var canShoot: bool = true
var playerTexture: Texture
var isHit: bool = false
var canSpawnTrack: bool = true
var trackSpawnTimer: float = 0.05

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		playerName = get_tree().get_first_node_in_group("test").text
		playerSpriteId = get_tree().current_scene.playerColorId
		$Camera2D.enabled = true
		if spawnPos != Vector2.ZERO:
			global_position = spawnPos
			
		var spawnArea = get_tree().current_scene.find_child("Spawns").get_child(0)
		spawnArea.progress_ratio = randf()
		global_position = spawnArea.global_position

@rpc()
func set_spawn(pos: Vector2):
	global_position = pos

func respawn(pos: Vector2):
	set_spawn(pos)

func _process(delta):
	#spr.texture = playerTexture
	$Node2D/Label.text = playerName
	$Node2D.global_rotation = 0
	$Node2D.global_position.y = global_position.y - 48
	$Node2D.global_position.x = global_position.x
	
	if $Sprite2D.texture != playerSprites[playerSpriteId-1][0]:
		$Sprite2D.texture = playerSprites[playerSpriteId-1][0]

func _physics_process(delta):
	velocity = Vector2.ZERO
	if is_multiplayer_authority():
		if canControl and not isHit:
			characterInput(delta)
	position.x = clamp(position.x, 0+16, 4008-16)
	position.y = clamp(position.y, 0+16, 2456-16)
	move_and_slide()

func hit(bullet, target):
	#emit_signal("playerHit", bullet, target)
	get_tree().current_scene.onPlayerHit(bullet, target)
	

func shoot():
	var cannon = get_node("Cannon")
	spawnBullet.rpc(position, cannon.global_transform)

func createTrack():
	var spawner = get_node("TrackSpawner")
	spawnTracks.rpc(position, spawner.global_transform)

func characterInput(delta):
	if Input.is_action_pressed("p1_up"):
		velocity = Vector2(0, -speed).rotated(rotation)
	if Input.is_action_pressed("p1_down"):
		velocity = Vector2(0, speed).rotated(rotation)
	if Input.is_action_pressed("p1_right"):
		rotation += rotateSpeed * delta
	if Input.is_action_pressed("p1_left"):
		rotation -= rotateSpeed * delta
	
	if not velocity == Vector2.ZERO and canSpawnTrack:
		createTrack()
		canSpawnTrack = false
		await get_tree().create_timer(trackSpawnTimer).timeout
		canSpawnTrack = true
	
	# var dir = Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down")
	# velocity = dir * speed
	if Input.is_action_pressed("p1_shoot") and canShoot:
		shoot()
		
		canShoot = false
		await get_tree().create_timer(bulletTimer).timeout
		canShoot = true

@rpc("call_local")
func spawnTracks(pos:Vector2, forward: Transform2D):
	var main = get_tree().current_scene
	var track = trackPre.instantiate()
	main.add_child(track)
	track.transform = forward

@rpc("call_local")
func spawnBullet(pos:Vector2, forward:Transform2D):
	var main = get_tree().current_scene
	var bullet = bulletPre.instantiate()
	var bulletSpr = bullet.get_child(0)
	bullet.set_multiplayer_authority(self.name.to_int())
	bullet.connect("hitPlayer", hit)
	bulletSpr.texture = playerSprites[playerSpriteId-1][1]
	main.add_child(bullet)
	bullet.transform = forward
	
	muzzleflash.visible = true
	await get_tree().create_timer(0.1).timeout
	muzzleflash.visible = false

@rpc()
func _keepAlive() -> bool:
	return true
