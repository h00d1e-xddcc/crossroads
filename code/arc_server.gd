extends Node

@export var port : int = 23456
@export var ip : String = '127.0.0.1'

func just_spawn() :
	pass
	#add_user(1)
	#arc.user = $"/root/main/map/users/1"

func open_host() :
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 32)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(connect_user)

func connect_user(id) :
	add_user(id)
	
func add_user(id) :
	var user = preload("res://prefabs/entity/user.tscn").instantiate()
	user.name = str(id)
	$/root/main/map/users.add_child(user)
	
func _on_connect() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
