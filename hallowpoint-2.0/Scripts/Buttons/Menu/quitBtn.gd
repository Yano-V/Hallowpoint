extends TextureButton

@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var anim_duration: float = 0.15

var default_scale: Vector2

func _ready() -> void:
	default_scale = scale
	pivot_offset = size / 2
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", hover_scale, anim_duration)

func _on_mouse_exited() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", default_scale, anim_duration)
