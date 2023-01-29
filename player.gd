extends CharacterBody3D


@export var SPEED = 8
@export var DECEL = 2
@export var DASH_SPEED = 24
@export var DASH_DISTANCE = 8
@export var jump_velocity = 4.5

@onready var camera:Camera3D = $Camera3d
@onready var anim_player = $AnimationPlayer

var look_sensitivity = 0.2
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.3
var velocity_y = 0
var dashing = false
var dashed_dist = 0
var mouse_dir = Vector3()
var dash_dir = Vector3()

func dash(dist_remaining) -> Vector3:
	var vel = Vector3()
	#var pos = Vector2(self.position.x, self.position.z)	
	if dist_remaining > 0:
		if dash_dir == Vector3():
			dash_dir = (mouse_dir - position).normalized()
		vel = dash_dir * DASH_SPEED	
		print("dash vel: ", vel)
	else:
		dashing = false
		dashed_dist = 0
		dash_dir = Vector3()
		print("finished dash")
	return vel

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("attack"):
		pass	

func _physics_process(delta):	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		

	if dashing:	
		# probably breaks on some edge case where the dash gets stopped
		dashed_dist += velocity.length() * delta
		velocity = dash(DASH_DISTANCE - dashed_dist)
		print("upcoming dash remaining: ", DASH_DISTANCE - dashed_dist)
	else:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", 'move_backward')
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, DECEL)
			velocity.z = move_toward(velocity.z, 0, DECEL)
	move_and_slide()
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		pass
	
func _unhandled_input(event):
	# Handle outofbodyvision.
	if Input.is_action_pressed("outofbodyvision"):
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * look_sensitivity))
			camera.rotate_x(deg_to_rad(-event.relative.y * look_sensitivity))
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

	if Input.is_action_just_pressed("dash"):
		dashing = true	

	if event is InputEventMouseMotion:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 100
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		ray_query.collide_with_areas = true
		var res = space.intersect_ray(ray_query)
		if "position" in res:
			mouse_dir = res["position"]

func _on_hit_box_area_entered(area):
	if area.is_in_group("enemy"):
		print("enemy hit")
