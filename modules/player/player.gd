class_name Player extends Area2D

@export
var pad_speed_pixels_per_second = 150
@export
var sync_position: Vector2

var paddle_size
var screen_size

enum Location {EASTERN, WESTERN}

var input : float = 0

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

	paddle_size = get_node("Sprite2D").get_texture().get_size()
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)

	self.position = sync_position

	# We expect this to be 420, 420
	print('player _ready position %s' % str(position))
	print('player _ready sync_position %s' % str(sync_position))

	multiplayer.server_disconnected.connect(self._on_server_disconnected)

func _on_server_disconnected():
	print('_on_server_disconnected, closing game')
	get_tree().quit()

func _physics_process(delta):
	if $PlayerInput.is_multiplayer_authority():
		$PlayerInput.send_input.rpc_id(1, Input.get_axis("move_paddle_up", "move_paddle_down"))
	if !is_multiplayer_authority():
		self.position = sync_position
		return
	
	position.y += input * pad_speed_pixels_per_second * delta
	
	# Update sync variables, which will be replicated to everyone else
	sync_position = position

func _on_area_entered(body):
	if constants.BALL_COLLISION_LAYER == body.get_collision_layer():
		print('wall _on_area_entered collision with ball')
		signals.emit_signal('collision_with_paddle')
