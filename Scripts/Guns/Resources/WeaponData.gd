class_name WeaponData extends Resource

@export var name : StringName
@export var weaponType: String
@export var damage: float

@export var magSize : int
@export var bulletsInMag: int
@export var reserveAmmo : int
@export var defaultReserveAmmo : int

@export var weaponCaliber: String

@export var allowsFireSelection : bool
@export var fireModes: Array
@export var selectedFireMode: StringName
@export var selectedFireModeIndex: int

@export var isBoltAction : bool

@export var cadency : float
@export var recoil: Vector3

#used for pickup weapons, so we can add to the weaponSelector
@export var weaponScene : String
@export var weaponPickupScene : String
@export var weaponSpawnPosition : Vector3
@export var weaponImage : Texture

#Used for the external POV of the player
@export var weaponExternalScene : PackedScene

@export var cameraADSPosition: Vector3
