
extends AudioStreamPlayer


func _ready() -> void:
	# Start the assigned startup music automatically.
	if stream != null and not playing:
		play()


func play_bgm(new_stream: AudioStream) -> void:
	if new_stream == null:
		push_warning("MusicManager: Audio stream is missing.")
		return

	if stream == new_stream and playing:
		return

	stream = new_stream
	play()


func play_music() -> void:
	var startup_music: AudioStream = load(
		"res://Assets/Audio/STARTUP (REVISED).mp3"
	)
	play_bgm(startup_music)


func stop_bgm() -> void:
	stop()


func stop_music() -> void:
	stop()


func pause_bgm() -> void:
	stream_paused = true


func resume_bgm() -> void:
	stream_paused = false
	if not playing and stream != null:
		play()
