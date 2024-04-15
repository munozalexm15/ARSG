"# ARSG" 
## TODO:


###GUN PLAY
 - Add interaction with weapons (grab other guns if pressing certain key) 
 
##WEAPON LIST
 - Shotgun
 - AR
 - Silenced weapons
 - Weapon variations

###WEAPON FEEL
 - Bullet impact decals
 - Camera shake when shooting
 - Add clipping gun prevention
 - Tweak states transitions (IE: Players cancel the swap weapon action if they start running)

###UI / HUD
 - Menu
 - Show player state (crouched, running, standing -> like COD1)
 - Show Health(maybe?)
 
###OTHER:
 - Clean weapon / hands code (maybe state machine)
 - Make pickup variations of M14 and USP [ X ]
 - Preload all possible pickup weapons on scene start, so it doesn't lag when picking up ones -> You could have a pool of created objects and store them somewhere, hidden with process and physics process disabled and instead of instantiating a new object, take one object out of the pool and set it up. When you want to destroy it, don't free it, just store it in the pool 