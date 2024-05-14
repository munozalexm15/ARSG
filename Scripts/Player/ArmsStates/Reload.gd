extends ArmsState

var bullet_reload_time : float
var wantsToShoot = false

func enter(_msg := {}):
	arms.animationPlayer.play("Reload")

func physics_update(delta):
	mouse_swap_weapon_logic()
	swap_weapon()
	
	if Input.is_action_just_pressed("Fire"):
		wantsToShoot = true

func _on_animation_player_animation_finished(anim_name):
	if (anim_name != "Reload"):
		return
	
	arms.actualWeapon.hide()
	if arms.actualWeapon.weaponData.weaponType == "Shotgun" or arms.actualWeapon.weaponData.weaponType == "Revolver":
		bullet_reload_time = arms.actualWeapon.weaponData.reloadTime / arms.actualWeapon.weaponData.magSize
		reload_bullet_by_bullet()
	else:
		arms.reloadTimer.start()

func _on_animation_player_animation_started(anim_name):
	if anim_name == "Reload":
		return
	
	arms.reloadTimer.stop()

func mouse_swap_weapon_logic():
	if not Input.is_action_pressed("Next Weapon") or not Input.is_action_pressed("Previous Weapon"):
		return
	
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
		
	state_machine.transition_to("SwappingWeapon")
	
func swap_weapon():
	if not Input.is_action_pressed("Primary weapon") or not Input.is_action_pressed("Secondary weapon"):
		return
	
	if Input.is_action_just_pressed("Primary weapon"):
		if arms.actual_weapon_index != 0:
			arms.actual_weapon_index = 0
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		
	if Input.is_action_just_pressed("Secondary weapon"):
		if arms.actual_weapon_index != 1:
			arms.actual_weapon_index = 1
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)

	state_machine.transition_to("SwappingWeapon")


func _on_reload_timer_timeout():
	arms.reloadTimer.stop()
	arms.reloadTimer.wait_time = arms.actualWeapon.weaponData.reloadTime
	
	ammo_behavior()
	state_machine.transition_to("Idle")
	

func reload_bullet_by_bullet():
	if arms.actualWeapon.weaponData.bulletsInMag == arms.actualWeapon.weaponData.magSize:
		_on_reload_timer_timeout()
		return
	
	if wantsToShoot:
		wantsToShoot = false
		state_machine.transition_to("Idle")
		return
	
	await get_tree().create_timer(bullet_reload_time).timeout
	if arms.actualWeapon.weaponData.reserveAmmo == 0 or arms.actualWeapon.weaponData.weaponType != "Shotgun":
		state_machine.transition_to("Idle")
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
