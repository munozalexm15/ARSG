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
func play_sfx_3d(soundPath: String, parentId: String, busLayout : String, maxDistance : float):
	var audioSteam : AudioStream = load(soundPath)
	var stream = AudioStreamPlayer3D.new()
	stream.stream = audioSteam
	
	var player_ref : Player = null
	for x : Player in Network.game.players_node.get_children():
		if x.name == parentId:
			player_ref = x
	
	stream.max_distance = maxDistance
	stream.bus = busLayout
	stream.connect("finished",
					func(): 
						stream.queue_free()
						player_ref.groundCheck_Raycast.playAudio = true
						)
	if player_ref != null:
		#for shooting sounds which don't have to be removed if switching weapon
		if busLayout == "Weapons" and maxDistance > 50:
			player_ref.weapon_sounds.add_child(stream)
		#for having all the sounds of reload in a node that can be used to be removed if reload cancelling
		elif busLayout == "Weapons" and maxDistance < 50:
			player_ref.player_sounds.add_child(stream)
		#all other kind of sounds player by the user
		else:
			player_ref.add_child(stream)
		stream.play()
