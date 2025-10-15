extends MeshInstance3D
@onready var viewport_node = $"../../../ArcadeViewport/ArcadeGameSubViewport"

func _ready():
	var screen_material = StandardMaterial3D.new()
	set_surface_override_material(0, screen_material)
	if not is_instance_valid(viewport_node):
		print("CRITICAL ERROR: Absolute SubViewport path failed.")
		return
	var viewport_texture = ViewportTexture.new()
	viewport_texture.viewport_path = viewport_node.get_path() 
	screen_material.albedo_texture = viewport_texture
	screen_material.emission_enabled = true 
	screen_material.emission = Color.WHITE
	screen_material.emission_texture = viewport_texture 
	screen_material.emission_energy_multiplier = 1.0
