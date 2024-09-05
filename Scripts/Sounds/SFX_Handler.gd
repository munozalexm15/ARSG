extends Node


#custom method. 
#It creates a new audioStreamPlayer every time is called, therefore it won't cut if it is started again.
func play_sfx(sound: AudioStream, parent: Node, busLayout : String):
	var stream = AudioStreamPlayer.new()

	stream.stream = sound
	stream.bus = busLayout
	stream.connect("finished", Callable(stream, "queue_free"))
	
	parent.add_child(stream)
	stream.play()

func play_sfx_3d(sound: AudioStream, parent: Node, busLayout : String):
	var stream = AudioStreamPlayer3D.new()

	stream.stream = sound
	stream.bus = busLayout
	stream.connect("finished", Callable(stream, "queue_free"))
	
	parent.add_child(stream)
	stream.play()
