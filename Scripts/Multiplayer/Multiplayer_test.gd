extends Node2D

const PORT = 8080
var peer = ENetMultiplayerPeer.new()
@export var playArea: PackedScene
@export var player_scene: PackedScene
@onready var menu = $"GuiMenu"
@onready var connectMenu = $"GuiMenu/VBoxContainer"
@onready var tankChoiceMenu = $"GuiMenu/TankChoice"
@onready var ipArea = $"GuiMenu/VBoxContainer/IPAddress"
@onready var nameBox = $"GuiMenu/VBoxContainer/NameBox"
@onready var hud = $"CanvasLayer/Hud"

var playerColorId: int = 0
#
func _ready():
	$"GuiMenu/TankChoice/HBoxContainer/Black".connect("chooseColor", SetPlayerColor)
	$"GuiMenu/TankChoice/HBoxContainer/Green".connect("chooseColor", SetPlayerColor)
	$"GuiMenu/TankChoice/HBoxContainer/Red".connect("chooseColor", SetPlayerColor)
	$"GuiMenu/TankChoice/HBoxContainer/Blue".connect("chooseColor", SetPlayerColor)

func _on_host_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	connectMenu.visible = false
	tankChoiceMenu.visible = false

func _on_server_btn_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	connectMenu.visible = false
	tankChoiceMenu.visible = false
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	player.player_entered.connect(set_player_name)
	player.playerSpriteId = playerColorId
	player.connect("playerHit", onPlayerHit)
	#hud.Scores.push
	if not is_multiplayer_authority():
		print("Player %s connected and is %s" % [id, playerColorId])
		
	var spawnArea = find_child("Spawns").get_child(0)
	spawnArea.progress_ratio = randf()
	player.spawnPos = spawnArea.global_position
	player.set_spawn.rpc(spawnArea.global_position)
	find_child("Spawns").call_deferred("add_child", player)

func setRespawn(player):
	var spawnArea = find_child("Spawns").get_child(0)
	spawnArea.progress_ratio = randf()
	#player.global_position = spawnArea.global_position
	player.respawn(spawnArea.global_position)

func onPlayerHit(bullet, target):
	print("!")
	if bullet.is_multiplayer_authority():
		$CanvasLayer/Hud.score = $CanvasLayer/Hud.score + 1
		#target.isHit = true
		#setRespawn(target)
		print("Target: %s is hit: %s" % [target.name, target.isHit])
	elif target.is_multiplayer_authority():
		setRespawn(target)

func set_player_name(player):
	player.playerName = nameBox.text
#
func SetPlayerColor(ColorId):
	for i in $GuiMenu/TankChoice/HBoxContainer.get_children():
		if i.tankColorId != ColorId:
			i.button_pressed = false
	playerColorId = ColorId

func _on_join_pressed():
	# var error = peer.create_client(ipArea.text, PORT)
	var error = peer.create_client("localhost", PORT)
	if error:
		print("dis")
	else:
		multiplayer.multiplayer_peer = peer
		connectMenu.visible = false
		tankChoiceMenu.visible = false

