extends Node2D

const PORT = 8080
var peer = ENetMultiplayerPeer.new()
@export var playArea: PackedScene
@export var player_scene: PackedScene

func _on_host_pressed():
    peer.create_server(PORT)
    multiplayer.multiplayer_peer = peer
    multiplayer.peer_connected.connect(_add_player)
    _add_player()

func _add_player(id = 1):
    var player = player_scene.instantiate()
    player.name = str(id)
    # call_deferred("add_child", player)
    find_child("Player_Spawn").call_deferred("add_child", player)

func _on_join_pressed():
    peer.create_client("localhost", PORT)
    multiplayer.multiplayer_peer = peer