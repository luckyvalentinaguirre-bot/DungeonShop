# 01 — Sistema de Economía

> Reglas de dinero, precios, mercado y transacciones. Es el motor numérico del
> juego. Debe ser **parametrizable desde Resources** (nada de números mágicos) y
> **testeable sin UI**. Estados: 🟢 decidido · 🟡 provisional · 🔴 abierto.

---

## 1. Objetivos de diseño

- La economía debe **premiar decisiones**, no farmeo ciego.
- Precios dinámicos por **oferta y demanda**, no listas fijas.
- Que quebrar sea posible pero **recuperable** (nada de *game over*).
- Todo el *tuning* vive en `resources/config/EconomyConfig.tres`.

## 2. Moneda

- Unidad: **coronas** (oro). Submúltiplo cosmético: **cobres** (100 cobres = 1 corona) 🟡.
- El jugador tiene una **caja** (`WalletComponent`). Puede tener **deuda** (saldo
  negativo tras préstamo), pero no gastar por debajo de su límite de crédito.

## 3. Formación de precios 🟡

Precio de venta sugerido de un objeto:

```
precio_base × mult_calidad × mult_demanda × mult_reputación × mult_evento
```

| Factor | Origen | Rango típico |
|--------|--------|--------------|
| `precio_base` | `ItemData.base_value` | dato del objeto |
| `mult_calidad` | calidad del objeto fabricado (ver [Crafting](05_Crafting.md)) | 0.6–2.0 |
| `mult_demanda` | oferta/demanda del mercado para esa categoría | 0.5–2.0 |
| `mult_reputación` | prestigio de la tienda / afinidad de facción | 0.9–1.5 |
| `mult_evento` | eventos activos (guerra sube armas, festival sube lujo) | 0.5–3.0 |

El **precio final lo fija el jugador**; el sistema solo sugiere. Cobrar por encima
del "precio justo" del cliente baja su ánimo y puede romper la venta
(ver [Customers](02_Customers.md) y negociación).

## 4. Oferta y demanda 🟡

- Cada **categoría** de objeto (armas, armaduras, pociones, herramientas, mágicos)
  tiene un índice de **demanda** que sube al haber clientes que la piden y baja al
  saturar el mercado con ventas.
- La demanda **regresa a la media** con el tiempo (no se queda disparada).
- Eventos del reino sesgan la demanda (guerra → armas/armaduras; plaga → pociones).
- Modelo concreto y curvas: `DemandModel` (system), parámetros en `EconomyConfig`.

## 5. Compra de materiales (costes)

- Los materiales se compran en el **Mercado Bajo** a proveedores.
- Precio de material = `mat_base × mult_mercado_semanal × mult_proveedor`.
- Los precios de materiales fluctúan por **semana** (ver ciclo temporal en el GDD).
- Proveedores mejores (desbloqueables) dan mejor precio/rareza pero exigen
  reputación (ver [Reputation](04_Reputation.md)).

## 6. Transacción (flujo)

```
Cliente acepta precio → EconomySystem.resolve_sale(item, price, buyer) →
  mueve oro (buyer.wallet → player.wallet) →
  retira item del inventario →
  actualiza demanda de la categoría →
  emite EventBus.item_sold(item, price, buyer) →
  reputación y logros escuchan la señal
```

`resolve_sale` es **puro y testeable**: recibe datos, devuelve un resultado, emite
señal. No toca la UI.

## 7. Gastos recurrentes 🟡

Para dar tensión suave sin castigar:

- **Mantenimiento** de la tienda por semana (sube con ampliaciones).
- **Salarios** de empleados contratados (ver [Progression](06_Progression.md)).
- **Impuestos** de la Corona proporcionales a ingresos (gancho de facción).

Si la caja no cubre gastos → se ofrece **préstamo** (deuda con interés), nunca
quiebra irreversible.

## 8. Modelo de clases (composición, sin UI)

| Clase | Tipo | Responsabilidad única |
|-------|------|-----------------------|
| `EconomyConfig` | `Resource` (data) | Todos los parámetros de tuning económico |
| `PriceCalculator` | system (puro) | Calcula precio sugerido a partir de factores |
| `DemandModel` | system (puro) | Mantiene y actualiza demanda por categoría |
| `MarketSystem` | system | Precios de materiales, ciclo semanal, proveedores |
| `TransactionResolver` | system | Ejecuta ventas/compras, mueve oro e inventario |
| `WalletComponent` | component | Oro/deuda de una entidad; API de cobro/pago |
| `LedgerService` | system | Registro contable para UI de finanzas y logros |

`EconomySystem` (fachada en `scripts/economy/`) coordina estos servicios y expone
una API mínima a la capa de managers. Cada pieza < 200 líneas.

## 9. Señales (EventBus)

- `item_sold(item: ItemData, price: int, buyer)`
- `material_purchased(material: ItemData, qty: int, cost: int)`
- `wallet_changed(owner, new_balance: int)`
- `market_week_advanced(week: int)`
- `player_bankrupt_warning()` (dispara oferta de préstamo)

## 10. Preguntas abiertas

- 🟢 *(cerrada en Fase 3)* Negociación = **automática por ánimo** del cliente
  (ver [Customers](02_Customers.md) §7). Se implementará el `HaggleResolver` en Fase 4.
- 🟢 *(cerrada en Fase 3)* Demanda = **global por categoría** en v1.0 (más simple de
  calibrar). La segmentación por facción/barrio queda como posible ampliación post-v1.
- 🟡 Valores concretos de `EconomyConfig` se calibran con playtesting (arrancan con
  los defaults de `resources/config/EconomyConfig.tres`).

## 11. Estado de implementación (Fase 3) ✅

Implementado y cubierto por tests (`tests/unit/`, runner `tests/run_tests.gd`):
`EconomyConfig`, `ItemData`/`ItemInstance` (mínimos), `PriceCalculator`,
`DemandModel`, `WalletComponent`, `MarketSystem`, `TransactionResolver` y la fachada
`EconomySystem`. Demo ejecutable sin UI en `scenes/dev/DevRoot.tscn`.
**Pendiente para fases posteriores:** mover inventario en las transacciones (Fase 5),
gastos recurrentes/préstamos y `LedgerService` (Fase 9), señal `player_bankrupt_warning`.
