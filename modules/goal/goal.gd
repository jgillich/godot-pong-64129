extends Area2D

enum Location {EASTERN, WESTERN}

func init(screen_size, location):
	var box = RectangleShape2D.new()
	var goal_size = screen_size
	goal_size.x = 25
	box.extents = goal_size
	$CollisionShape2D.set_shape(box)

	if location == Location.EASTERN:
		# TODO unhardcode and get info from Main, which gets it from Player
		$CollisionShape2D.position.y = 50
	elif location == Location.WESTERN:
		# TODO unhardcode and get info from Main, which gets it from Player
		$CollisionShape2D.position.y = 50
		$CollisionShape2D.position.x = screen_size.x + (0.5 * goal_size.x)
	else:
		push_error('goal init received unexpected location %d in its init method' % location)

	return self

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(body):
	print('goal _on_area_entered %d' % body.get_collision_layer())
	if constants.BALL_COLLISION_LAYER == body.get_collision_layer():
		print('wall _on_area_entered cogillision with ball')
		signals.emit_signal('collision_with_goal')
