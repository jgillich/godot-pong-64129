extends Area2D

@export
var pad_speed_pixels_per_second = 150
@export
var sync_position: Vector2

var paddle_size
var screen_size

enum Location {EASTERN, WESTERN}

func is_local_authority():
	return $Networking/MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

#func init(screen_size, location):
#	$Networking.sync_position.y = screen_size.y / 2
#	self.position.y = screen_size.y / 2
#
#	print('player init for location %s' % location)
#
#	if location == Location.EASTERN:
#		# TODO unhardcode and compute it based on the screen_size
#		$Networking.sync_position.x = 50
#		self.position.x = 50
#	elif location == Location.WESTERN:
#		# TODO unhardcode and compute it based on the screen_size
#		$Networking.sync_position.x = screen_size.x - 50
#		self.position.x = screen_size.x - 50
#	else:
#		push_error('player init received unexpected location %s in its init method' % location)
#
#	print('player init moved player to sync_position %s, and therefore position %s' % [str($Networking.sync_position), str(self.position)])
#
#	return self

func _ready():
	# int constructor taking a string is currently broken :(
	# https://github.com/godotengine/godot/issues/44407
	# https://github.com/godotengine/godot/issues/55284
	$Networking/MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

	paddle_size = get_node("Sprite2D").get_texture().get_size()
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)

	self.position = $Networking.sync_position

	# We expect this to be 420, 420
	print('player _ready position %s' % str(position))
	print('player _ready sync_position %s' % str($Networking.sync_position))

	multiplayer.server_disconnected.connect(self._on_server_disconnected)

func _on_server_disconnected():
	print('_on_server_disconnected, closing game')
	get_tree().quit()

func _move_paddle(delta):
	var paddle_position = self.position

	if (paddle_position.y > 0 and Input.is_action_pressed("move_paddle_up")):
		paddle_position.y += -pad_speed_pixels_per_second * delta
	if (paddle_position.y < screen_size.y and Input.is_action_pressed("move_paddle_down")):
		paddle_position.y += pad_speed_pixels_per_second * delta

	self.position = paddle_position

func _physics_process(delta):
	if !is_local_authority():
		self.position = $Networking.sync_position
		return

	# Move locally
	_move_paddle(delta)
	
	# Update sync variables, which will be replicated to everyone else
	$Networking.sync_position = position

func _on_area_entered(body):
	if constants.BALL_COLLISION_LAYER == body.get_collision_layer():
		print('wall _on_area_entered collision with ball')
		signals.emit_signal('collision_with_paddle')
