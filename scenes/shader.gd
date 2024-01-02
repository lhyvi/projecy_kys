@tool 
extends ColorRect

func _ready():
	ResourceManager.shader = self
	var mat = material as ShaderMaterial
	var grad = mat.get_shader_parameter("gradient") as GradientTexture1D
	grad.connect("changed", load_shader_offsets)
	if not Engine.is_editor_hint():
		set_shader_gradient(ResourceManager.get_gradient())
	else:
		load_shader_offsets()

# func _on_node_added(_node):
# 	get_parent().move_child.call_deferred(self, -1)
	
func load_shader_offsets():
	print("Loaded gradient values to shader")
	var mat = material as ShaderMaterial
	var grad = mat.get_shader_parameter("gradient") as GradientTexture1D
	var grad_offsets = grad.gradient.offsets;
	mat.set_shader_parameter("gradient_offsets", grad_offsets)
	mat.set_shader_parameter("palette_color_count", grad_offsets.size())

func set_shader_gradient(gradient: Gradient):
	var mat = material as ShaderMaterial
	var grad = mat.get_shader_parameter("gradient") as GradientTexture1D
	grad.gradient = gradient
