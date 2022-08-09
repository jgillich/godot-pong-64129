extends Node2D

var screen_size

func _dynamically_draw_walls():
	var wall_scene = load('res://modules/wall/wall.tscn')
	var wall_script = load('res://modules/wall/wall.gd')

	var northern_wall = wall_scene.instantiate().init(screen_size, wall_script.Location.NORTHERN)
	northern_wall.name = 'northern_wall'
	var southern_wall = wall_scene.instantiate().init(screen_size, wall_script.Location.SOUTHERN)
	southern_wall.name = 'southern_wall'

	get_tree().current_scene.add_child(northern_wall)
	get_tree().current_scene.add_child(southern_wall)

func _dynamically_draw_goals():
	var goal_scene = load('res://modules/goal/goal.tscn')
	var goal_script = load('res://modules/goal/goal.gd')

	var eastern_goal = goal_scene.instantiate().init(screen_size, goal_script.Location.EASTERN)
	eastern_goal.name = 'eastern_goal'
	var western_goal = goal_scene.instantiate().init(screen_size, goal_script.Location.WESTERN)
	western_goal.name = 'western_goal'

	get_tree().current_scene.add_child(eastern_goal)
	get_tree().current_scene.add_child(western_goal)

func _ready():
	screen_size = get_viewport_rect().size
	_dynamically_draw_walls()
	_dynamically_draw_goals()
