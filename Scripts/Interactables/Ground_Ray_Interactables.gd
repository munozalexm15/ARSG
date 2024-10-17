extends RayCast3D

@onready var player : Player = $".."

var playAudio : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_colliding() and get_collider() is Ground_Handler and player.headBobbing_vector.y < -0.98 and not player.ASP_Footsteps.playing and (player.state_machine.state.name == "Walk" or player.state_machine.state.name == "Run"):
		if player.isPauseMenuOpened or Network.game.chatText.has_focus() or player.health <= 0 or not playAudio:
			return
		var collision : GroundData = get_collider().groundData
		var sound = collision.walk_sound.pick_random()
		playAudio = false
		SFXHandler.play_sfx_3d.rpc(sound.resource_path, player.name, "Environment", 20.0)
	
	if is_colliding() and get_collider() is WeaponInteractable:
		#player.hud.pickupAmmoContainer.visible = true
		var weapon = get_collider()
		for x in player.arms.weaponHolder.get_child_count():
			if weapon == null:
				continue
			if weapon.weaponData.weaponCaliber == player.arms.weaponHolder.get_child(x).weaponData.weaponCaliber and weapon.weaponData.reserveAmmo > 0:
				get_weapon_ammo.rpc(player.name.to_int(), x, weapon.id)
		
@rpc("any_peer", "call_local", "reliable")
func get_weapon_ammo(player_id : int, weaponHolder_child_pos : int, pickupWeaponId : int):
	var pickupWeapon = null
	#search the dropped weapon in the map
	for index in Network.game.interactables_node.get_child_count():
		var interactable = Network.game.interactables_node.get_child(index)
		if interactable is WeaponInteractable and interactable.id == pickupWeaponId:
			pickupWeapon = interactable
			
	if pickupWeapon == null:
		return
	
	 #search the player and the weapon it is using
	for p : Player in Network.game.players_node.get_children():
		if p.name.to_int() == player_id:
			var weapon = p.arms.weaponHolder.get_child(weaponHolder_child_pos)
			var pickupReserveAmmo = pickupWeapon.weaponData.reserveAmmo
			if weapon.get_multiplayer_authority() == player.get_multiplayer_authority():
				if weapon.weaponData.weaponCaliber == pickupWeapon.weaponData.weaponCaliber:
					weapon.weaponData.reserveAmmo += pickupReserveAmmo
			pickupWeapon.queue_free()
