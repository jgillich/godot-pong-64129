extends Area2D

@export
var starting_ball_speed_pixels_per_second = 220

@export
var sync_position: Vector2

var current_ball_speed_pixels_per_second = starting_ball_speed_pixels_per_second
var initial_direction_of_ball = Vector2(-1, 0)
var direction_of_ball = initial_direction_of_ball

func is_local_authority():
	return $Networking/MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

func _ready():
	print('ball _ready')

	signals.collision_with_paddle.connect(_on_collision_with_paddle)
	signals.collision_with_wall.connect(_on_collision_with_wall)
	signals.collision_with_goal.connect(_on_collision_with_goal)

func _physics_process(delta):
	print('ball _physics_process checking if I am local authority')
	if !is_local_authority():
		print('\tball _physics_process I am not')
		position = $Networking.sync_position
		return
	print('\tball _physics_process I am')

	# Move locally
	# Calculate Ball's new position and update it
	self.position += direction_of_ball * current_ball_speed_pixels_per_second * delta
	
	# Update sync variables, which will be replicated to everyone else
	$Networking.sync_position = position

func _on_collision_with_paddle():
	direction_of_ball.x = -direction_of_ball.x
	current_ball_speed_pixels_per_second *= 1.1
	direction_of_ball.y = randf() * 2.0 - 1
	direction_of_ball = direction_of_ball.normalized()

func _on_collision_with_wall():
	direction_of_ball.y = -direction_of_ball.y

func _on_collision_with_goal():
	var RESET_POSITION = get_viewport_rect().size * 0.5 # Ball goes to screen center
	self.position = RESET_POSITION # Updates the server's ball position
	$Networking.sync_position = RESET_POSITION # Updates the client's ball position
	
	print('ball _on_collision_with_goal moved ball back to center point of screen, at position %s' % str(self.position))

	current_ball_speed_pixels_per_second = starting_ball_speed_pixels_per_second # reset ball speed

	# Reverse the initial direction of the ball, alternating which player gets to serve
	initial_direction_of_ball.x = -initial_direction_of_ball.x
	direction_of_ball = initial_direction_of_ball
