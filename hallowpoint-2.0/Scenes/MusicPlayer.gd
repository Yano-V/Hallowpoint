
extends AudioStreamPlayer

# Stores the playback position of each BGM.
var saved_positions: Dictionary = {}

# Tracks the currently selected music.
var current_bgm_path: String = ""

# Startup music.
const STARTUP_MUSIC: String = "res://Assets/Audio/STARTUP (REVISED).mp3"


func _ready() -> void:
	# Start the assigned startup music automatically.
	if stream != null:
		current_bgm_path = stream.resource_path

		if not playing:
			play()


func play_bgm(new_stream: AudioStream) -> void:
	if new_stream == null:
		push_warning("MusicPlayer: Audio stream is missing.")
		return

	var new_bgm_path: String = new_stream.resource_path

	if new_bgm_path.is_empty():
		push_warning("MusicPlayer: BGM has no resource path.")
		return

	# If the requested music is already active,
	# continue playing without restarting.
	if current_bgm_path == new_bgm_path:
		if playing:
			stream_paused = false
			return

		var resume_position: float = saved_positions.get(
			new_bgm_path, 0.0
		)

		play(resume_position)
		return

	# Save the previous BGM's playback position.
	if current_bgm_path != "" and playing:
		saved_positions[current_bgm_path] = get_playback_position()

	# Stop the previous BGM.
	stop()

	# Assign the new BGM.
	stream = new_stream
	current_bgm_path = new_bgm_path

	# Resume from the saved position, if available.
	var start_position: float = saved_positions.get(
		new_bgm_path, 0.0
	)

	play(start_position)


func play_music() -> void:
	var startup_music: AudioStream = load(STARTUP_MUSIC)
	play_bgm(startup_music)


func stop_bgm() -> void:
	# Save playback position before stopping.
	if current_bgm_path != "" and playing:
		saved_positions[current_bgm_path] = get_playback_position()

	stop()
	current_bgm_path = ""


func stop_music() -> void:
	stop_bgm()


func pause_bgm() -> void:
	stream_paused = true


func resume_bgm() -> void:
	if stream == null:
		return

	if playing:
		stream_paused = false
	else:
		var resume_position: float = saved_positions.get(
			current_bgm_path, 0.0
		)

		play(resume_position)


func reset_bgm(bgm_path: String) -> void:
	# Forget the saved playback position of a specific BGM.
	saved_positions.erase(bgm_path)
