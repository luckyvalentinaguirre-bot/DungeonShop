class_name ShopEnums
extends RefCounted
## Enumeraciones base de Dungeon Shop (arranque desde cero, Etapa 1-2).
## Se mantiene minimal a proposito; se amplia por etapas.

## Categoria de objeto expuesto. Determina en que muebles puede colocarse.
enum Category {
	WEAPON,     # espadas, dagas, arcos, lanzas, hachas, martillos, bastones
	ARMOR,      # cascos, pecheras, guantes, botas, escudos, capas
	POTION,     # pociones, frascos, ingredientes liquidos
	MATERIAL,   # materias primas (hierro, cuero, cristales...)
	MAGIC,      # objetos magicos / accesorios
	MISC,       # varios / decoracion vendible
}

## Tipo de mueble (estructura vs. mobiliario que expone objetos).
enum FurnitureKind {
	SHELF,      # estanteria (varios puntos de colocacion)
	COUNTER,    # mostrador (atencion + exposicion)
	DISPLAY,    # vitrina (objetos raros/legendarios)
	DECOR,      # decoracion sin puntos de colocacion
}

static func category_name(c: int) -> String:
	match c:
		Category.WEAPON: return "Arma"
		Category.ARMOR: return "Armadura"
		Category.POTION: return "Poción"
		Category.MATERIAL: return "Material"
		Category.MAGIC: return "Objeto mágico"
		_: return "Varios"
