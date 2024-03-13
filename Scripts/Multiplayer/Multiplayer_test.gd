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

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	player.player_entered.connect(set_player_name)
	player.playerSpriteId = playerColorId
	# call_deferred("add_child", player)
	find_child("Player_Spawn").call_deferred("add_child", player)

func set_player_name(player):
	player.playerName = nameBox.text
#
func SetPlayerColor(tankColorId):
	playerColorId = tankColorId

func _on_join_pressed():
	# var error = peer.create_client(ipArea.text, PORT)
	var error = peer.create_client("localhost", PORT)
	if error:
		print("dis")
	else:
		multiplayer.multiplayer_peer = peer
		connectMenu.visible = false
		tankChoiceMenu.visible = false

#func _on_multiplayer_spawner_spawned(node: Node):
	##node.changeColor.rpc
	##if node.get_multiplayer_authority() == multiplayer.get_unique_id():
	#if node.is_multiplayer_authority():
		#print(node.get_multiplayer_authority())
		#node.changeColor.rpc(multiplayer.get_unique_id(), playerColorId)
