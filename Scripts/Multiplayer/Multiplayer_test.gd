extends Node2D

const PORT = 10001

var connection_error = "";
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
	
	if DisplayServer.get_name() == "headless":
		print("Start Headless")
		_on_server_btn_pressed()

func _on_host_pressed():
	var peer = create_peer(false, true)
	#peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	_add_player()
	connectMenu.visible = false
	tankChoiceMenu.visible = false

func _on_server_btn_pressed():
	var peer = create_peer(true, true)
	#peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	connectMenu.visible = false
	tankChoiceMenu.visible = false
func _on_join_pressed():
	#var error = peer.create_client(ipArea.text, PORT)
	#var error = peer.create_client("localhost", PORT)
	#var error = peer.create_client(ipArea.text)
	var peer = null
	if ipArea.text == "":
		peer = create_peer(false, false, "localhost")
	else:
		peer = create_peer(true, false, ipArea.text)
		
	if connection_error:
		print("Could not create network: %s" % connection_error)
	else:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_disconnected.connect(_remove_player)
		connectMenu.visible = false
		tankChoiceMenu.visible = false
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	player.player_entered.connect(set_player_name)
	player.playerSpriteId = playerColorId
	player.connect("playerHit", onPlayerHit)
	#hud.Scores.push
	if is_multiplayer_authority():
		print("Player %s connected and is %s" % [id, playerColorId])
		
	var spawnArea = find_child("Spawns").get_child(0)
	spawnArea.progress_ratio = randf()
	player.spawnPos = spawnArea.global_position
	player.set_spawn.rpc(spawnArea.global_position)
	find_child("Spawns").call_deferred("add_child", player)

func create_peer(websocket: bool, isServer: bool, url: String = "") -> MultiplayerPeer:
	var peer: MultiplayerPeer = null
	if websocket:
		peer = WebSocketMultiplayerPeer.new()
	else:
		print("Creating a LAN client")
		peer = ENetMultiplayerPeer.new()
	
	if isServer:
		connection_error = peer.create_server(PORT)
	elif websocket:
		connection_error = peer.create_client(url)
	else:
		connection_error = peer.create_client(url, PORT)
		print("ERror: %s" %connection_error)
		
	
	return peer

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


func _remove_player(id):
	#var node = get_tree().current_scene.find_child(str(id))
	var node = get_node("Spawns/"+str(id))
	if node != null:
		node.queue_free()
