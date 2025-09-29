extends CharacterBody3D


const SPEED = 5.0
const SENSITIVITY = 0.002


@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D 


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var rotation_input = Vector2.ZERO

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("Left", "Right", "Backwards", "Forward")
	var direction = Vector3.ZERO
	
	if input_dir.length() > 0:
		var current_basis = global_transform.basis
		
		var forward_vector = -current_basis.z.normalized()
		var right_vector = current_basis.x.normalized()
		
		direction = (forward_vector * input_dir.y) + (right_vector * input_dir.x)
		direction = direction.normalized()

	if direction.length_squared() > 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * 10.0)
		velocity.z = lerp(velocity.z, 0.0, delta * 10.0)
	
	# 5. EXECUTE MOVEMENT
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		rotation_input = event.relative
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if rotation_input != Vector2.ZERO:
		rotate_y(-rotation_input.x * SENSITIVITY)
		
		camera_pivot.rotate_x(-rotation_input.y * SENSITIVITY)
		
		var rot_x = camera_pivot.rotation.x
		rot_x = clamp(rot_x, deg_to_rad(-90), deg_to_rad(90))
		camera_pivot.rotation.x = rot_x
		rotation_input = Vector2.ZERO
