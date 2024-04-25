extends ArmsState

func enter(_msg := {}):
	if _msg.has("drop_weapon"):
		drop_weapon(_msg.get("drop_weapon"))

	
	arms.animationPlayer.play("SwapWeapon")

func physics_update(delta):
	pass

func drop_weapon(name):
	var weapon_Ref = null
	for x in arms.weaponHolder.get_child_count():
		if arms.weaponHolder.get_child(x).weaponData.name == name:
			weapon_Ref = arms.weaponHolder.get_child(x)
	
	if weapon_Ref == null:
		return
		
	var weapon_to_spawn = load(weapon_Ref.weaponData.weaponPickupScene)
	var spawnedWeapon = weapon_to_spawn.instantiate()
	
	spawnedWeapon.weaponData.reserveAmmo = weapon_Ref.weaponData.reserveAmmo
	spawnedWeapon.weaponData.bulletsInMag = weapon_Ref.weaponData.bulletsInMag

	#if both weapons have the same caliber, when dropping the actual weapon it will lose all its reserve ammo 
	if arms.weaponHolder.get_child(0).weaponData.weaponCaliber == arms.weaponHolder.get_child(1).weaponData.weaponCaliber:
		spawnedWeapon.weaponData.reserveAmmo = 0
	
	spawnedWeapon.isAlreadyGrabbed = true
	spawnedWeapon.set_global_transform(arms.weaponHolder.get_global_transform())
	var world = get_tree().get_root().get_child(0)
	world.add_child(spawnedWeapon)

	arms.weaponHolder.remove_child(weapon_Ref)
	
	arms.actual_weapon_index = 0
	arms.actualWeapon = arms.weaponHolder.get_child(arms.actual_weapon_index)
	
	arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)

func _on_animation_player_animation_finished(anim_name):
	if anim_name != "SwapWeapon":
		return
	
	loadWeapon(arms.actual_weapon_index)
	arms.actualWeapon = arms.weaponHolder.get_child(arms.actual_weapon_index)
	arms.reloadTimer.wait_time = arms.actualWeapon.weaponData.reloadTime
	
	if arms.player.state != "Run":
		state_machine.transition_to("Idle")
	
	if arms.actual_weapon_index == 0:
		arms.player.hud.animationPlayer.play("swap_gun", -1, 4.0, false)
	else:
		arms.player.hud.animationPlayer.play("swap_gun_backwards", -1, 4.0, false)
	
	state_machine.transition_to("Idle")
	#elif arms.player.state == "Run":
		#arms.animationPlayer.play("Run")

func loadWeapon(index):
	for x in arms.weaponHolder.get_child_count():
		arms.weaponHolder.get_child(x).process_mode = Node.PROCESS_MODE_DISABLED
		arms.weaponHolder.get_child(x).visible = false

	arms.weaponHolder.get_child(index).process_mode = Node.PROCESS_MODE_ALWAYS
	arms.weaponHolder.get_child(index).visible = true
