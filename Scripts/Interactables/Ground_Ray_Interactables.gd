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
				get_weapon_ammo.rpc(player.arms.weaponHolder.get_child(x), weapon)
		
@rpc("any_peer", "call_local", "reliable")
func get_weapon_ammo(weapon : Weapon, pickupWeapon : WeaponInteractable):
	var pickupReserveAmmo = pickupWeapon.weaponData.reserveAmmo
	weapon.weaponData.reserveAmmo += pickupReserveAmmo
	pickupWeapon.queue_free()
