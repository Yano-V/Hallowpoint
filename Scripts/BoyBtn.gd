extends TextureButton

@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var anim_duration: float = 0.15

var default_scale: Vector2
var is_locked: bool = false

func _ready() -> void:
	default_scale = scale
	pivot_offset = size / 2
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	if is_locked or disabled: return
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", hover_scale, anim_duration)

func _on_mouse_exited() -> void:
	if is_locked: return
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", default_scale, anim_duration)

# This function fixes the error and locks the button
func lock_button(stay_enlarged: bool = false) -> void:
	is_locked = true
	disabled = true
	var target_scale = hover_scale if stay_enlarged else default_scale
	var tween = create_tween()
	tween.tween_property(self, "scale", target_scale, anim_duration)

# This function unlocks the button later
func unlock_button() -> void:
	is_locked = false
	disabled = false
	# Instantly snap back to normal scale without waiting for a tween
	scale = default_scale
