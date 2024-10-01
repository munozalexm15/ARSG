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


#rpc because it is intended to be used only for shooting, walking, reload, etc.
@rpc("any_peer", "call_local", "reliable")
func play_sfx_3d(sound: AudioStream, parentId: String, busLayout : String):
	var stream = AudioStreamPlayer3D.new()
	var player_ref = null
	for x : Player in Network.game.players_node.get_children():
		if x.name == parentId:
			player_ref = x
	
	stream.stream = sound
	stream.bus = busLayout
	stream.connect("finished", Callable(stream, "queue_free"))
	
	player_ref.add_child(stream)
	stream.play()
