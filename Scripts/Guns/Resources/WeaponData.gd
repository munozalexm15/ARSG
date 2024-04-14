class_name Weapon extends Resource

@export var name : StringName
@export var magSize : int
@export var bulletsInMag: int
@export var reserveAmmo : int
@export var reloadTime: float
@export var isAutomatic: bool
@export var cadency : float
@export var recoil: Vector3
#used for pickup weapons, so we can add to the weaponSelector
@export var weaponScene : PackedScene
@export var weaponSpawnPosition : Vector3
