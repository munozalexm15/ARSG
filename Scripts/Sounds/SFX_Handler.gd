extends Node


#custom method. 
#It creates a new audioStreamPlayer every time is called, therefore it won't cut if it is started again.
func play_sfx(sound: AudioStream, parent: Node):
	var stream = AudioStreamPlayer3D.new()

	stream.stream = sound
	stream.connect("finished", Callable(stream, "queue_free"))
	
	parent.add_child(stream)
	stream.play()
