class_name Cell extends Node2D

signal pressed(cell: Cell)

@export var select_color: Color = Color.LIGHT_BLUE
@export var raised_color: Color = Color.RED
@export var danger_color: Color = Color.VIOLET
@export var default_color: Color = Color.WHITE

@onready var sprite = $Sprite2D as Sprite2D
@onready var area2d = $Area2D as Area2D

var disabled = false:
	set(value):
		disabled = value
		if disabled:
			set_raise(false)

var selectable = false:
	set(value):
		selectable = value
		update_color()

var danger = false:
	set(value):
		danger = value
		update_color()

var pos: Vector2
var raised = false

func init(init_pos:Vector2) -> void:
	self.pos = init_pos

func set_selectable(sel: bool) -> void:
	selectable = sel

func update_color() -> void:
	if raised:
		modulate = raised_color
		return
	if selectable:
		modulate = select_color
		return
	if danger:
		modulate = danger_color
		return
	modulate = default_color

func set_raise(new_raised) -> void:
	if new_raised == raised:
		return
	if new_raised == true:
		raise()
	else:
		unraise()
	raised = new_raised
	update_color()


func raise() -> void:
	sprite.position += Vector2(0,5)

func unraise() -> void:
	sprite.position -= Vector2(0,5)


func clear() -> void:
	selectable = false
	danger = false


func _on_area_2d_mouse_entered() -> void:
	if disabled:
		return
	set_raise(true)

func _on_area_2d_mouse_exited() -> void:
	if disabled:
		return
	set_raise(false)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			pressed.emit(self)
	pass # Replace with function body.
