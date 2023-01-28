extends CharacterBody3D


@export var SPEED = 15
@export var jump_velocity = 4.5

@onready var camera:Camera3D = $Camera3d
@onready var anim_player = $AnimationPlayer
@onready var hitbox = $"Camera3d/WeaponPivot/Blood Sword/HitBox"

var look_sensitivity = 0.2
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.3
var velocity_y = 0



func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("attack"):
		pass
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", 'move_backward')
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		pass
	
func _input(event):
	# Handle outofbodyvision.
	if Input.is_action_pressed("outofbodyvision"):
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * look_sensitivity))
			camera.rotate_x(deg_to_rad(-event.relative.y * look_sensitivity))
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _on_hit_box_area_entered(area):
	if area.is_in_group("enemy"):
		print("enemy hit")
