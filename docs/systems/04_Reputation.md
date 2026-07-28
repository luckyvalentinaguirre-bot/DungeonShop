# 04 — Sistema de Reputación

> El prestigio de tu tienda: una moneda **social** separada del oro. Abre facciones,
> clientela de élite, proveedores y contenido. Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- Ser un **eje de progreso paralelo** al dinero (puedes ser rico y poco respetado).
- Recompensar el **buen trato** y la **especialización**, no solo el volumen.
- Estructurar el desbloqueo de contenido de forma legible.

## 2. Dos capas de reputación

1. **Prestigio global** (un número/estrellas): la fama general de la tienda.
   Determina el rango de la tienda (bronce→plata→oro→legendaria) y la cantidad/
   calidad de clientela genérica.
2. **Afinidad por facción** (un valor por facción, ver [Lore](../Lore.md) §4):
   determina qué clientela de élite, materiales y encargos se desbloquean.

## 3. Cómo sube y baja 🟡

Sube por:
- Ventas satisfactorias (cliente contento, precio justo).
- Cumplir **encargos** a tiempo y con calidad.
- Equipar bien a héroes que triunfan (afinidad de Gremio).
- Participar en eventos del reino (ver [Events](07_Events.md)).

Baja por:
- Clientes maltratados o estafados (precio abusivo).
- Encargos fallidos o entregados tarde.
- Vender objetos defectuosos que perjudican a héroes.

Cambios grandes vienen de hitos (misiones, eventos), no de cada venta suelta.

## 4. Qué desbloquea la reputación

| Umbral | Desbloqueo típico |
|--------|-------------------|
| Prestigio ↑ | Rango de tienda, más clientes, ampliaciones (ver [Progression](06_Progression.md)) |
| Afinidad Gremio ↑ | Héroes de élite, encargos de expedición |
| Afinidad Corona ↑ | Contratos grandes, permisos de expansión de barrio |
| Afinidad Arcano ↑ | Recetas y materiales mágicos |
| Afinidad Artesanos ↑ | Estaciones y técnicas de fabricación |
| Afinidad Buhoneros ↑ | Materiales exóticos de contrabando |

## 5. Tensiones de facción 🟢 (cerrado en Fase 2)

Algunas facciones están **en tensión**: ganar mucho con una resta **levemente** a su
rival. Crea decisiones estratégicas sin obligar a elegir bando; el roce es **suave y
nunca bloqueante**. Detalle narrativo en [WorldBible](../WorldBible.md#5-tensiones-entre-facciones).

| Par enfrentado | Motivo |
|----------------|--------|
| **La Corona ⚔ Los Buhoneros** | Ley vs. contrabando (eje "legalidad") |
| **Círculo Arcano ⚔ La Corona** | Magia libre vs. control estatal |
| **Gremio ⚔ Liga de Artesanos** | Rivalidad amistosa: usar vs. fabricar el equipo |

**Neutrales:** el **Pueblo llano** no está enfrentado con nadie. Los pesos concretos
del roce viven en `ReputationConfig` (calibrar en Fase 3+).

## 6. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `ReputationConfig` | Resource | Umbrales, pesos y tensiones de facción |
| `FactionData` | Resource | Definición de cada facción |
| `ReputationSystem` | system | Mantiene prestigio y afinidades; aplica deltas |
| `ReputationComponent` | component | Punto de aporte de una entidad a la reputación |

`ReputationSystem` escucha señales de venta/encargo/héroe del `EventBus` y traduce
en deltas; no conoce la UI.

## 7. Señales (EventBus)

- `reputation_changed(faction, old, new)`
- `prestige_rank_up(new_rank)`
- `faction_unlocked(faction)`

## 8. Preguntas abiertas

- 🟢 *(cerrada en Fase 2)* Pares enfrentados definidos (§5); magnitud "suave" en `ReputationConfig`.
- 🟡 Fórmula exacta de conversión venta→reputación (calibrar con Economy en Fase 3).
