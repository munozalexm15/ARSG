extends RayCast3D

@onready var player : Player = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding() and get_collider() is GroundData and player.headBobbing_vector.y < -0.98 and not player.ASP_Footsteps.playing:
		var collision : GroundData = get_collider().groundData
		var sound : AudioStreamOggVorbis = collision.walk_sound.pick_random()
		player.ASP_Footsteps.stream = sound
		player.ASP_Footsteps.play()
	
	if is_colliding() and get_collider() is WeaponInteractable:
		#player.hud.pickupAmmoContainer.visible = true
		var isInHolder = false
		var weapon = get_collider()
		for x in player.arms.weaponHolder.get_child_count():
			if weapon.weaponData.weaponCaliber == player.arms.weaponHolder.get_child(x).weaponData.weaponCaliber and weapon.weaponData.reserveAmmo > 0:
				print(weapon.weaponData.reserveAmmo )
				get_weapon_ammo.rpc(multiplayer.get_unique_id(), x, weapon.id)
		
@rpc("any_peer", "call_local", "reliable")
func get_weapon_ammo(player_id : int, weaponHolder_child_pos : int, pickupWeaponId : int):
	var pickupWeapon = null
	
	#search the dropped weapon in the map
	for index in Network.game.interactables_node.get_child_count():
		var interactable = Network.game.interactables_node.get_child(index)
		if interactable is WeaponData and interactable.id == pickupWeaponId:
			pickupWeapon = interactable
			print("yea")
	
	 #search the player and the weapon it is using
	for player : Player in Network.game.players_node.get_children():
		if player.name.to_int() == player_id:
			var weapon = player.arms.weaponHolder.get_child(weaponHolder_child_pos)
			var pickupReserveAmmo = pickupWeapon.weaponData.reserveAmmo
			weapon.weaponData.reserveAmmo += pickupReserveAmmo
			pickupWeapon.queue_free()
