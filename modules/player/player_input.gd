extends Node3D

@onready var player = get_parent()

func _ready():
	set_multiplayer_authority(str(player.name).to_int())

@rpc
func send_input(input : float):
	if input < -1 and input > 1:
		# someone's trying to cheat :(
		return
	player.input = input
