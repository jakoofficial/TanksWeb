extends Node2D

const PORT = 8080
var peer = ENetMultiplayerPeer.new()
@export var playArea: PackedScene
@export var player_scene: PackedScene
@onready var menu = $"GuiMenu"
@onready var ipArea = $"GuiMenu/VBoxContainer/IPAddress"
@onready var nameBox = $"GuiMenu/VBoxContainer/NameBox"

func _on_host_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	menu.visible = false

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	player.player_entered.connect(set_player_name)
	# call_deferred("add_child", player)
	find_child("Player_Spawn").call_deferred("add_child", player)
func set_player_name(player):
	player.playerName = nameBox.text
	
func _on_join_pressed():
	# var error = peer.create_client(ipArea.text, PORT)
	var error = peer.create_client("localhost", PORT)
	if error:
		print("dis")
	else:
		multiplayer.multiplayer_peer = peer
		menu.visible = false
