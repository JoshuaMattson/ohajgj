extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with func"mouse dir: ", tion body.

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)

func _draw():
	var center = get_global_mouse_position()
	var radius = 25
	var angle_from = 0 
	var angle_to = 360
	var color = Color(1.0, 0.0, 0.0)
	#draw_circle_arc(center, radius, angle_from, angle_to, color)
	draw_circle(center, radius, color)

func _input(event):
	if event is InputEventMouseMotion:
		queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
