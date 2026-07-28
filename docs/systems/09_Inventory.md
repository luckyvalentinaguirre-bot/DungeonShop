# 09 — Sistema de Inventario

> Modelo de almacenamiento de objetos: almacén, estantería de venta e inventarios de
> NPCs. Es una **pieza reutilizable** (por composición) usada por tienda, clientes y
> héroes. Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- Un **único modelo de inventario** reutilizable, no uno por caso (DRY).
- Separar **modelo** (datos puros, testeable) de **vista** (UI de arrastrar/soltar).
- Soportar **stacks**, capacidad y categorías sin acoplar a la UI.

## 2. Modelo (datos puros)

- **`ItemInstance`**: una instancia concreta de un objeto = referencia a `ItemData`
  + estado propio (calidad, rasgos aplicados, durabilidad, defectos, cantidad si
  apilable). Distinto de `ItemData` (la plantilla inmutable). Ver [Items](../Items.md).
- **`Inventory`**: colección de `ItemInstance` con capacidad y reglas de apilado.
  API pura: `add`, `remove`, `has`, `count`, `move_to`. Sin nodos, testeable.
- **`InventoryComponent`**: nodo que envuelve un `Inventory` para colgarlo de una
  escena (tienda, cliente, héroe) — la vía de **composición**.

## 3. Contenedores del juego 🟡

| Contenedor | Qué guarda | Capacidad |
|------------|------------|-----------|
| **Almacén** | Stock general + materiales | Ampliable (ver [Progression](06_Progression.md)) |
| **Estantería/expositor** | Objetos a la venta (visibles al cliente) | Por *slots* de expositor |
| **Inventario de héroe/cliente** | Lo que compra o trae de mazmorra | Pequeño |

La estantería es especial: lo que está en ella es lo que la clientela puede comprar,
y su **presentación** afecta a demanda/ánimo (gancho de progresión/decoración).

## 4. Apilado (stacks) 🟡

- Los **materiales** y consumibles se apilan (misma `ItemData` y estado compatible).
- Los objetos con estado único (arma fabricada con rasgos concretos) **no** se
  apilan: cada uno es un `ItemInstance` propio.
- Regla de apilado vive en `Inventory`, no en la UI.

## 5. Movimiento de objetos

- Entre contenedores vía `Inventory.move_to(other, item, qty)` (operación atómica:
  o se mueve entero o no se mueve).
- La UI (`InventoryView` + `DraggableComponent` + `DropSlot`) solo **traduce**
  gestos del usuario en llamadas al modelo; no contiene reglas.

## 6. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `ItemInstance` | data | Instancia concreta con estado |
| `Inventory` | system (puro) | Colección + reglas de capacidad/apilado/movimiento |
| `InventoryComponent` | component | Envuelve un `Inventory` en una escena |
| `InventoryView` | ui | Presentación (grid, slots) |
| `DropSlot` / `DraggableComponent` | component/ui | Arrastrar y soltar |

## 7. Señales

- `Inventory` emite señales locales: `item_added`, `item_removed`, `changed`.
- Cruces relevantes al `EventBus`: `shelf_changed` (para recalcular demanda/venta).

## 8. Persistencia

`Inventory` implementa el contrato `ISaveable` (ver [Save](08_Save.md)):
`capture_state()`/`restore_state()` serializan sus `ItemInstance`.

## 9. Preguntas abiertas

- 🔴 ¿Inventario por *slots* con cuadrícula visible (estilo Moonlighter) o por lista
  con capacidad numérica? Afecta a UI y sensación. Recomendado: cuadrícula para
  almacén/estantería (táctil y *cozy*), lista para materiales a granel.
- 🟡 Reglas exactas de compatibilidad de apilado por estado.
