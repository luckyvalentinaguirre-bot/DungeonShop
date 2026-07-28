# Economía — referencia de valores y contenido

> Este documento acompaña a [systems/01_Economy](systems/01_Economy.md): allí está
> **cómo funciona** la economía; aquí van los **valores concretos** (moneda, tablas,
> curvas placeholder) que alimentarán `resources/config/EconomyConfig.tres`. Todos
> los números son 🟡 provisionales, para calibrar en Fase 3 con playtesting.

---

## 1. Moneda

- **Corona** (oro): unidad principal.
- **Cobre**: 100 cobres = 1 corona (cosmético/precios finos) 🟡.
- Formato en UI: "1 250 ⬤" (icono de corona).

## 2. Rangos de precio de referencia (placeholder 🟡)

| Categoría | Valor base típico (coronas) |
|-----------|------------------------------|
| Poción común | 8 – 25 |
| Herramienta | 5 – 40 |
| Arma común | 30 – 120 |
| Armadura común | 40 – 160 |
| Objeto mágico | 100 – 600 |
| Material bruto | 2 – 20 |
| Material raro | 30 – 150 |

## 3. Multiplicadores (rangos de diseño)

Ver fórmula en [systems/01](systems/01_Economy.md#3-formación-de-precios):

| Factor | Rango objetivo |
|--------|----------------|
| `mult_calidad` (0–5) | 0.6 – 2.0 |
| `mult_demanda` | 0.5 – 2.0 |
| `mult_reputación` | 0.9 – 1.5 |
| `mult_evento` | 0.5 – 3.0 |

## 4. Gastos recurrentes (placeholder 🟡)

| Gasto | Cuándo | Referencia |
|-------|--------|-----------|
| Mantenimiento tienda | semanal | escala con ampliaciones |
| Salario dependiente | semanal | ~% de ingresos medios |
| Impuesto de la Corona | semanal | % de ingresos |
| Interés de préstamo | mientras haya deuda | tasa suave |

## 5. Préstamos (red de seguridad)

- Disponibles cuando la caja no cubre gastos (evita quiebra irreversible).
- Límite de crédito ligado al rango de tienda.
- Interés suave; pensados como rescate, no como estrategia óptima.

## 6. Curva de riqueza objetivo (sensación 🟡)

- **Bronce:** decenas–cientos de coronas por jornada. Cada compra importa.
- **Plata/Oro:** cientos–miles; entran empleados y encargos grandes.
- **Legendaria:** decenas de miles; economía a gran escala, eventos mayores.

El objetivo es crecimiento **percibido y constante** sin trivializar decisiones
(los costes escalan con la ambición). Los valores exactos se ajustan en Fase 3+.

## 7. Dónde viven estos datos

Todo lo anterior se convierte en `resources/config/EconomyConfig.tres` y tablas
asociadas — **nunca** como literales en el código (ver [Arquitectura](systems/00_Architecture.md)).
