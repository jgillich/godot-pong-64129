extends Node2D

@export
var player_scene = preload("res://modules/player/player.tscn")

@export
var ball_scene = preload("res://modules/ball/ball.tscn")

@export
var ip = "localhost"

@export
var port = 4242

# List of players in this session. Left player is at index 0, second player is index 1.
# All other players are just spectators.
var players = []

func _enter_tree():
	# Start the server if Godot is passed the "--server" argument,
	# and start a client otherwise.
	if "--server" in OS.get_cmdline_args():
		print('network _enter_tree starting server')
		start_network(true)
	else:
		print('network _enter_tree starting client')
		start_network(false)

func start_network(server: bool):
	var peer = ENetMultiplayerPeer.new()
	if server:
		# Listen to peer connections, and create new player for them
		multiplayer.peer_connected.connect(self.create_player)

		# Listen to peer disconnections, and destroy their players
		multiplayer.peer_disconnected.connect(self.destroy_player)

		peer.create_server(port)
		print('network start_network server listening on ip %s and port %d' % [ip, port])
	else:
		peer.create_client(ip, port)

	multiplayer.set_multiplayer_peer(peer)

func create_player(id : int):
	# Instantiate a new player for this client.
	if len(players) == 0:
		print('network create_player creating new eastern Player with ID %d' % id)
		var east_player_scene = player_scene.instantiate()

		# Set the name, so players can figure out their local authority
		east_player_scene.name = str(id)

		east_player_scene.get_node('Networking').sync_position = Vector2(50, 200)

		$Players.add_child(east_player_scene)

		print('network create_player we have set position to %s' % str(east_player_scene.position))
		print('network create_player we have set sync_position to %s ' % str(east_player_scene.get_node('Networking').sync_position))

		players.append(id)
	elif len(players) == 1:
		print('network create_player creating new western Player with ID %d' % id)
		var west_player_scene = player_scene.instantiate()
		west_player_scene.get_node('Networking').sync_position = Vector2(400, 200)

		# Set the name, so players can figure out their local authority
		west_player_scene.name = str(id)

		$Players.add_child(west_player_scene)
		players.append(id)

		print('network create_player creating ball')
		var the_ball_scene = ball_scene.instantiate()

		$Balls.add_child(the_ball_scene)
	else:
		print('network create_player creating new spectator with ID %d' % id)
		pass # Spectator

func destroy_player(id : int):
	print('network destroy_player destroying player with ID %d' % id)

	players.erase(id)

	# Delete this peer's node.
	$Players.get_node(str(id)).queue_free()
	
