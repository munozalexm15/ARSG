extends ArmsState

var bullet_reload_time : float
var wantsToShoot = false

func enter(_msg := {}):
	wantsToShoot = false
	
	arms.reloadTimer.wait_time = arms.actualWeapon.reload_sound.stream.get_length()
	
	if !arms.actualWeapon.weaponData.reloadsWithMagazine:
		bullet_reload_time = arms.actualWeapon.weaponData.reloadTime / arms.actualWeapon.weaponData.magSize
		reload_bullet_by_bullet()
	else:
		if arms.actualWeapon.weaponData.bulletsInMag > 0:
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Reload")
			arms.actualWeapon.reload_sound.play()
			arms.reloadTimer.wait_time = arms.actualWeapon.reload_sound.stream.get_length() + 0.2
		else:
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Full_Reload")
			arms.actualWeapon.full_reload_sound.play()
			arms.reloadTimer.wait_time = arms.actualWeapon.full_reload_sound.stream.get_length() + 0.2
		
		arms.reloadTimer.start()

func physics_update(_delta):
	mouse_swap_weapon_logic()
	swap_weapon()
	
	if Input.is_action_just_pressed("Fire"):
		wantsToShoot = true

func mouse_swap_weapon_logic():
	if Input.is_action_just_pressed("Next Weapon") or Input.is_action_just_pressed("Previous Weapon"):
		
		if Input.is_action_just_pressed("Next Weapon"):
			if arms.actual_weapon_index < arms.weaponHolder.get_child_count() -1:
				arms.actual_weapon_index += 1
			else:
				arms.actual_weapon_index = 0
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
			
		if Input.is_action_just_pressed("Previous Weapon"):
			if arms.actual_weapon_index < arms.weaponHolder.get_child_count() -1:
				arms.actual_weapon_index += 1
			else:
				arms.actual_weapon_index = 0
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		
		arms.actualWeapon.reload_sound.stop()
		arms.actualWeapon.full_reload_sound.stop()
		arms.reloadTimer.stop()
		state_machine.transition_to("SwappingWeapon")
	
func swap_weapon():
	if (Input.is_action_just_pressed("Primary weapon") and arms.actual_weapon_index != 0) or (Input.is_action_just_pressed("Secondary weapon") and arms.actual_weapon_index != 1):
	
		if Input.is_action_just_pressed("Primary weapon"):
			if arms.actual_weapon_index != 0:
				arms.actual_weapon_index = 0
				arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
			
		if Input.is_action_just_pressed("Secondary weapon") and arms.actual_weapon_index != 1:
			if arms.actual_weapon_index != 1:
				arms.actual_weapon_index = 1
				arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		
		arms.actualWeapon.reload_sound.stop()
		arms.actualWeapon.full_reload_sound.stop()
		arms.reloadTimer.stop()
		state_machine.transition_to("SwappingWeapon")
		


func _on_reload_timer_timeout():
	arms.reloadTimer.stop()
	
	ammo_behavior()
	arms.actualWeapon.reload_sound.play()
	state_machine.transition_to("Idle")
	

func reload_bullet_by_bullet():
	if arms.actualWeapon.weaponData.bulletsInMag == arms.actualWeapon.weaponData.magSize:
		_on_reload_timer_timeout()
		return
	
	if wantsToShoot:
		wantsToShoot = false
		arms.actualWeapon.reload_sound.play()
		state_machine.transition_to("Idle")
		return
	
	await get_tree().create_timer(bullet_reload_time).timeout
	arms.actualWeapon.reload_sound.play()
	if arms.actualWeapon.weaponData.reserveAmmo == 0:
		state_machine.transition_to("Idle", {"play_reload": false})
		return
	
	arms.actualWeapon.weaponData.bulletsInMag += 1
	arms.actualWeapon.weaponData.reserveAmmo -= 1
	arms.player.animationPlayer.play("reload")
	for x in arms.weaponHolder.get_child_count():
		if arms.weaponHolder.get_child(x) != arms.actualWeapon and arms.weaponHolder.get_child(x).weaponData.weaponCaliber == arms.actualWeapon.weaponData.weaponCaliber:
			arms.weaponHolder.get_child(x).weaponData.reserveAmmo -= 1
	
	reload_bullet_by_bullet()

func ammo_behavior():
	var ammoLeft = arms.actualWeapon.weaponData.bulletsInMag
	if (arms.actualWeapon.weaponData.magSize - ammoLeft) <= arms.actualWeapon.weaponData.reserveAmmo:
		arms.actualWeapon.weaponData.reserveAmmo -= arms.actualWeapon.weaponData.magSize - ammoLeft
		arms.actualWeapon.weaponData.bulletsInMag += arms.actualWeapon.weaponData.magSize - ammoLeft
	
	#If both weapons share the same caliber, subtract to both weapons the reserve ammo
		for x in arms.weaponHolder.get_child_count():
			if arms.weaponHolder.get_child(x) != arms.actualWeapon and arms.weaponHolder.get_child(x).weaponData.weaponCaliber == arms.actualWeapon.weaponData.weaponCaliber:
				arms.weaponHolder.get_child(x).weaponData.reserveAmmo -= arms.actualWeapon.weaponData.magSize - ammoLeft

#if not, give the remaining reserve ammo to the mag
	else:
		arms.actualWeapon.weaponData.bulletsInMag += arms.actualWeapon.weaponData.reserveAmmo
		arms.actualWeapon.weaponData.reserveAmmo = 0
	
func exit():
	if arms.actualWeapon.reload_sound.playing and arms.actualWeapon.reload_sound:
		arms.actualWeapon.reload_sound.stop()
