# ARSG

#LORE / GAME TYPE

- En un futuro distopico, a los ladrones y los exiliados se les ofrece la oportunidad de redención si deciden acceder al coliseo de la guerra, donde a los jugadores se les envia a diferentes guerras
de la historia de la humanidad, y donde tienen que demostrar que son capaces de avanzar en cada guerra hasta terminar volviendo al futuro. Si lo consiguen, se enfrentan al boss final (que es tu personaje
de una anterior run con todas tus habilidades). Si lo derrotan, se convertiran en el nuevo regente del coliseo, y seran los encargados de decidir si matar o enviar a los ladrones al coliseo de la guerra. 
(Básicamente, el juego es un loop infinito pero en cada run encarnas a un ladron diferente que tiene que enfrentarse a tu anterior personaje de la run)

- La idea es hacer un roguelike un jugador / cooperativo de disparos en primera persona, en los cuales los jugadores iran avanzando entre las diferentes gran guerras (cada nivel es una batalla famosa
que se elige de manera aleatoria de esa guerra).
En caso de llegar a la batalla final en cooperativo, se les obligara a pelear entre ellos en el coliseo para saber quien es el nuevo regente o aliarse para matar al boss final.

# CONTROLS:
- WASD: Movement
- Left click: Shoot
- Right click: Aim
- R: Reload
- V: Melee (WIP)
- Z: Flashlight
- F: Interact / Grab ammo / Swap weapon
- Shift: Sprint
- Control: Crounch
- Shift + Crouch: Slide
- Spacebar: Jump
- Q / E: Leaning

## TODO:

###ITEM LIST:
- Los jugadores, a parte de cambiar poder cambiar de arma con aquellas que sueltan los cofres (o el equivalente) o algun enemigo (normalmente, serán de una rareza inferior a la del nivel actual)

###ROGUELIKE:
- Morir y modo espectador
- Arreglar campo de tiro
- Hacer un sitema de eleccion de armas (a lo mw3 en modo supervivencia)

#### Niveles

- Fácil (Mundo uno): Armas de rareza común, enemigos basicos (soldados unicamente) y buffs genericos que no alteran la manera de jugar del jugador (más velocidad de recarga, etc.)
- Normal (Mundo dos): Armas de rareza rara y super rara, enemigos comunes y francotiradores / granaderos
- Dificil (mundo tres): Armas de rareza super rara y epica, enemigos comunes, francotiradores, granderos y enemigos del futuro
- Super Dificil (mundo cuatro): Armas de rareza epica y legendaria, enemigos comunes chetados, enemigos del futuro y tanques
- Pesadilla (mundo cinco): Armas de rareza legendaria e infame, enemigos del futuro, boss final

NOTA: Para avanzar hacia el siguiente nivel, hay que conseguir cumplir el objetivo de ese mapa (destruir un edificio, matar a x persona, etc.)

##### Rondas bonus
- Ronda bonus 1: Supervivencia contra los no muertos (Obtienes items que pueden dropear enemigos)
- Ronda bonus 2: Defensa de la posicion hasta la llegada de los refuerzos (Obtienes dinero que puedes comprar en una tienda, que ofrece armas de rarezas posiblementes mejores, items, etc.)

###LISTA DE ITEMS

#### Mecanicas para el jugador:
 - Una más no hace daño: Puedes llevar un arma adicional (2 armas en total)
 - Exoesqueleto: Un esqueleto adicional para mi persona favorita (Mecanica COD AW). Permite tener doble salto
	- Mejora exoesqueleto 1: Añade un impulso en cualquier direccion
	- Mejora exoesqueleto 2: Añade un impulso adicional en cualquier dirección y la opcion de hacer un golpetazo al suelo

#### A implementar:
 - Gatillo rapido: Aumenta la cadencia de disparo (stackeable hasta 3 veces) -> 10%, 20%, 30%
 - Pies rapidos: Aumenta la velocidad de movimiento (stackeable hasta 3 veces) -> 5%, 10%, 15%
 - Manos de hierro: Reduce el retroceso de las armas (stackeable hasta 3 veces) 10%, 15%, 20%
 - Balas perforantes: Tus balas pueden atravesar enemigos (stackeable hasta 2 veces) e inflingir sangrado (1% de salud que pierden por segundo). Algunos enemigos son inmunes a este efecto -> Un enemigo adicional, Dos enemigos adicionales
 - Balas incendiarias: Tus balas hacen que los enemigos tengan el estado de "en llamas" y pierden un % de salud por segundo durante 3 segundos -> 0,25%, 0,5%, 1%
 - Balas explosivas: tus balas pueden hacer daño en area a los enemigos cercanos y a enemigos con blindaje (tanques o lo que sea)
 - Manos agiles: Aumenta la velocidad de recarga en un 20%
 - Bola de nieve: Haces un 15% más de daño a los enemigos afectados con más de un estado (frio, en llamas, sangrado, mareado, etc.)
 - Mata moscas: Aumenta el daño a los enemigos voladores

#### A implementar (Ambientales):
- Fuerza imparable: No andaras lento en zonas de fango
- Oculto en las sombras: No serás visible en las zonas con poca visibilidad
- Sangre de muerto: Puedes fingir tu muerte en cualquier momento

### MECHANICS
 - Fix health system
 - Add healing items
 - Climb ladders (WIP)

## WEAPON LIST
 - Grenades
 - Rocket launcher / Grenade Launcher
 
### UI / HUD
 - Show player state (crouched, running, standing -> like COD1)
 - If shooting, add a little of camera zoom shake
 

