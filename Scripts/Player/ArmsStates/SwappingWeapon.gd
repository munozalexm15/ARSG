extends ArmsState

func enter(_msg := {}):
	if _msg.has("drop_weapon"):
		drop_weapon(_msg.get("drop_weapon"), _msg.get("pickup_weapon"), _msg.get("is_dropping_weapon"))

	arms.animationPlayer.play("SwapWeapon")
	
	if arms.actualWeapon.weaponData.weaponType == "Sniper" and Input.is_action_pressed("ADS"):
		arms.player.hud.aimAnimationPlayer.play("Aim", -1, -1, true)

func physics_update(delta):
	swap_weapon()
	mouse_swap_weapon_logic()

func drop_weapon(name, pickupWeapon, isSwapping):
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
	
	#weapon switching
	var spawnedWeaponScene = load(pickupWeapon.weaponData.weaponScene)
	spawnedWeapon = spawnedWeaponScene.instantiate()
	spawnedWeapon.position = pickupWeapon.weaponData.weaponSpawnPosition
	spawnedWeapon.handsNode = arms.get_path()
	
	arms.weaponHolder.add_child(spawnedWeapon)
	pickupWeapon.queue_free()
	
	arms.actual_weapon_index = 1
	
	arms.actualWeapon = arms.weaponHolder.get_child(arms.actual_weapon_index)
	
	#Give ammo to the other weapon reserve - RANDOMIZED, else: body.weaponData.bulletsInMag
	var randomMagAmmo = randf_range(0, pickupWeapon.weaponData.magSize)
	var randomReserveAmmo = randf_range(pickupWeapon.weaponData.reserveAmmo / 3, pickupWeapon.weaponData.reserveAmmo)
	
	if (not pickupWeapon.isAlreadyGrabbed and not isSwapping):
		arms.actualWeapon.weaponData.bulletsInMag = randomMagAmmo
		arms.actualWeapon.weaponData.reserveAmmo = randomReserveAmmo
	elif pickupWeapon.isAlreadyGrabbed:
		arms.actualWeapon.weaponData.bulletsInMag = pickupWeapon.weaponData.bulletsInMag
		arms.actualWeapon.weaponData.reserveAmmo = pickupWeapon.weaponData.reserveAmmo
	
	arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
	
	#if both weapons have the same caliber, add more ammo to both reserve
	if arms.actualWeapon.weaponData.weaponCaliber == arms.weaponHolder.get_child(0).weaponData.weaponCaliber:
		arms.weaponHolder.get_child(1).weaponData.reserveAmmo = arms.weaponHolder.get_child(0).weaponData.reserveAmmo
		arms.weaponHolder.get_child(0).weaponData.reserveAmmo = arms.weaponHolder.get_child(1).weaponData.reserveAmmo

	state_machine.transition_to("Idle")

func _on_animation_player_animation_finished(anim_name):
	if anim_name != "SwapWeapon":
		return
	
	if anim_name == "SwapWeapon" and state_machine.state.name == "Melee":
		return
	
	loadWeapon(arms.actual_weapon_index)
	arms.actualWeapon = arms.weaponHolder.get_child(arms.actual_weapon_index)
	arms.reloadTimer.wait_time = arms.actualWeapon.weaponData.reloadTime
	
	arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
	
	state_machine.transition_to("Idle")
	#elif arms.player.state == "Run":
		#arms.animationPlayer.play("Run")

func mouse_swap_weapon_logic():
	if Input.is_action_just_pressed("Next Weapon"):
		arms.actual_weapon_index = (arms.actual_weapon_index + 1) % arms.weaponHolder.get_child_count()
		
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
		return
		
	if Input.is_action_just_pressed("Previous Weapon"):
		arms.actual_weapon_index = (arms.actual_weapon_index - 1) % arms.weaponHolder.get_child_count()
		
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
		return
	
	
func swap_weapon():
	if Input.is_action_just_pressed("Primary weapon") and arms.actual_weapon_index != 0:
		arms.actual_weapon_index = 0
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
		return
		
	if Input.is_action_just_pressed("Secondary weapon") and arms.actual_weapon_index != 1:
		arms.actual_weapon_index = 1
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
		return

func loadWeapon(index):
	for x in arms.weaponHolder.get_child_count():
		arms.weaponHolder.get_child(x).process_mode = Node.PROCESS_MODE_DISABLED
		arms.weaponHolder.get_child(x).visible = false

	arms.weaponHolder.get_child(index).process_mode = Node.PROCESS_MODE_ALWAYS
	arms.weaponHolder.get_child(index).visible = true
