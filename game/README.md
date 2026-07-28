# Dungeon Shop — base nueva (desde cero)

Reinicio limpio siguiendo el documento-guía del diseñador. Solo **Etapa 1 + 2**:
una tienda 2D modular, vista 3/4, construida con piezas colocables y **lista para
colocar sprites de objetos en las estanterías** más adelante.

> El código anterior quedó **aislado** con archivos `.gdignore` en `scripts/`,
> `scenes/`, `tests/` y `resources/` (Godot no lo compila). Nada se borró.

## Estructura (`game/`)
- `scenes/Shop.tscn` — escena principal (main scene del proyecto).
- `scripts/Shop.gd` — construye la tienda modular: piso en rejilla, paredes,
  puerta, muebles, faroles con luz e iluminación ambiente (penumbra cálida "nivel 1").
- `scripts/AssetLibrary.gd` — **autoload**. Carga de sprites por ruta (con caché) y
  registro de objetos por id. Reemplazar un `.svg` por el sprite final = cambiar el
  archivo, sin tocar código.
- `scripts/FurnitureData.gd` — datos de un mueble: sprite, categorías que admite y
  **puntos de colocación** (huecos locales donde se posan los sprites de objetos).
- `scripts/FurnitureCatalog.gd` — definiciones de los muebles (estanterías, mostrador,
  vitrina) con sus huecos.
- `scripts/ShopFurniture.gd` — nodo de un mueble: dibuja su sprite, muestra los
  huecos como marcas tenues y expone `place_item(slot, textura, categoría)`.
- `scripts/ShopEnums.gd` — categorías de objeto y tipos de mueble.
- `art/` — **placeholders** vectoriales (piso, pared, puerta, mostrador, estantería,
  vitrina, farol). Se reemplazan por los sprites del diseñador en la misma ruta.

## Idea clave (puntos 6-7 del guía)
`ESTANTERÍA + SPRITE DEL OBJETO = OBJETO EXPUESTO`. Cada mueble define sus huecos y
qué categorías admite; el sistema coloca el sprite en un hueco automáticamente. No se
dibuja cada objeto sobre cada mueble.

## Qué se ve hoy
La tienda con piso, paredes, puerta al exterior, mostrador, 3 estanterías, una
vitrina y faroles encendidos. Los huecos de colocación se muestran como recuadros
tenues ("aquí van los objetos").

## Próximas etapas
- **Etapa 3** — objetos: inventario + colocar sprites reales en los huecos (ya hay
  `ShopFurniture.place_item`). Registrar sprites con `AssetLibrary.register_item`.
- **Etapa 4** — clientes que entran, caminan y compran.
- **Etapa 5+** — fabricación, economía, progresión, historia.
