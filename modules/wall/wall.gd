extends Area2D

enum Location {NORTHERN, SOUTHERN}

func init(screen_size, location):
	var box = RectangleShape2D.new()
	var wall_size = screen_size
	wall_size.y = 5
	box.extents = wall_size
	$CollisionShape2D.set_shape(box)

	if location == Location.NORTHERN:
		# TODO unhardcode and get info from Main, which gets it from Player
		$CollisionShape2D.position.x = 50
	elif location == Location.SOUTHERN:
		# TODO unhardcode and get info from Main, which gets it from Player
		$CollisionShape2D.position.x = 50
		$CollisionShape2D.position.y = screen_size.y + (0.5 * wall_size.y)
	else:
		push_error('wall init received unexpected location %s in its init method', location)

	return self

func _ready():
	area_entered.connect(_on_area_entered_entered)

func _on_area_entered_entered(body):
	print('wall _on_area_entered %s' % body.get_collision_layer())
	if constants.BALL_COLLISION_LAYER == body.get_collision_layer():
		print('wall _on_area_entered collision with ball')
		signals.emit_signal('collision_with_wall')
