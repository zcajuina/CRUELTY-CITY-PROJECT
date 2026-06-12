extends StaticBody3D
@onready var mesh: MeshInstance3D = $AUGMENT_BAG2/AUGMENT_BAG

@export_category("Texture Settings")
@export var albedo_texture: Texture2D:
	set(value):
		albedo_texture = value
		_apply_texture_to_material()

@export_range(0, 31) var surface_index: int = 0
@export var create_material_if_missing: bool = true
@export var texture_filter: BaseMaterial3D.TextureFilter = BaseMaterial3D.TEXTURE_FILTER_LINEAR

@export var AUG_NAME : String = ""

func _ready():
	await get_tree().process_frame
	if AUG_NAME == "" or Global.implants_owned.has(AUG_NAME):
		self.queue_free()
	if albedo_texture:
		_apply_texture_to_material()

func _apply_texture_to_material():
	if mesh == null:
		push_warning("MeshInstance3D has no mesh assigned!")
		return
	
	# Get or create material
	var material = mesh.get_surface_override_material(surface_index)
	
	if material == null:
		if create_material_if_missing:
			# Create new StandardMaterial3D
			material = StandardMaterial3D.new()
			mesh.set_surface_override_material(surface_index, material)
		else:
			push_warning("No material assigned to surface ", surface_index, " and create_material_if_missing is false.")
			return
	
	# Apply texture and settings
	material.albedo_texture = albedo_texture
	material.texture_filter = texture_filter
	
	# Optional: Set texture to repeat
	material.uv1_scale = Vector3.ONE
	material.uv1_offset = Vector3.ZERO

func interact():
	Global.implants_owned.append(AUG_NAME)
	Global._show_message(AUG_NAME + " ACQUISITION COMPLETE!", AUG_NAME + " CAN NOW BE EQUIPED ON THE MENU.")
	queue_free()
