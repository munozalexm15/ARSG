class_name WeaponData extends Resource

@export var name : StringName
@export var magSize : int
@export var bulletsInMag: int
@export var reserveAmmo : int
@export var weaponCaliber: String
@export var reloadTime: float
@export var allowsFireSelection : bool
@export var isAutomatic: bool
@export var cadency : float
@export var recoil: Vector3
#used for pickup weapons, so we can add to the weaponSelector
@export var weaponScene : String
@export var weaponPickupScene : String
@export var weaponSpawnPosition : Vector3
