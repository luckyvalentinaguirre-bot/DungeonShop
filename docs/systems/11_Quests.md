# 11 — Sistema de Misiones

> Objetivos guiados: tutoriales, encargos, arcos de personajes y el hilo narrativo
> principal. Estructura y da dirección al *sandbox*. Data-driven y desacoplado.
> Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- Dar **dirección** sin obligar: el jugador siempre sabe "qué hacer ahora", pero
  puede ignorar misiones opcionales y seguir jugando libre.
- Reutilizar el **mismo motor** para tutoriales, encargos y narrativa.
- Misiones como **datos**; el motor no conoce cada objetivo concreto.

## 2. Tipos de misión 🟡

| Tipo | Ejemplo | Origen |
|------|---------|--------|
| **Tutorial** | "Vende tu primer objeto" | Guion de inicio |
| **Encargo (commission)** | "Forja una espada de calidad ≥3 para Brida antes de 3 jornadas" | Cliente/héroe (ver [Customers](02_Customers.md)) |
| **De negocio** | "Alcanza la Tienda de Plata" | Progresión (ver [Progression](06_Progression.md)) |
| **De facción** | "Equipa a 5 héroes del Gremio" | Reputación |
| **Narrativa** | Arco del antecesor / la Fractura | Guion principal (ver [Lore](../Lore.md)) |

## 3. Anatomía de una misión (`QuestData`)

- **Requisitos de inicio:** condiciones para ofrecerse (rango, flags, evento).
- **Objetivos:** lista de `QuestObjective` (cada uno con una condición de completado
  medible por señales: "vender X", "fabricar con calidad ≥ N", "reputación ≥ M").
- **Recompensas:** oro, reputación, desbloqueos, ítems, avance narrativo.
- **Plazo (opcional):** jornadas límite (encargos).
- **Estado:** oculta → disponible → activa → completada/fallida.

## 4. Cómo se cumplen los objetivos (desacoplado)

`QuestSystem` **escucha el `EventBus`** (`item_sold`, `item_crafted`,
`reputation_changed`, `hero_returned`, …) y comprueba si algún objetivo activo se
satisface. Los sistemas de juego **no saben** que hay misiones observándolos → bajo
acoplamiento, alta extensibilidad. Un objetivo nuevo = un `QuestObjective`
componible que sabe a qué señal escuchar y cómo evaluarse.

## 5. Flujo

```
QuestSystem evalúa requisitos → ofrece misión (UI/diálogo) →
  jugador acepta (o auto-activa las principales) →
  señales del EventBus → QuestSystem actualiza objetivos →
  todos completos → entrega recompensas → emite quest_completed →
  puede encadenar la siguiente / avanzar arco
```

## 6. Relación con otros sistemas

- **Encargos** son misiones generadas por [Customers](02_Customers.md)/[Heroes](03_Heroes.md).
- **Eventos** ([Events](07_Events.md)) pueden abrir misiones; misiones pueden marcar
  flags que habilitan eventos. Se comunican por señales, no por acoplamiento directo.
- **Logros** ([Achievements](12_Achievements.md)) son parecidos pero **meta** (no dan
  recompensa de juego ni caducan) → sistema hermano, no el mismo.

## 7. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `QuestData` | Resource | Definición de misión (requisitos, objetivos, recompensas) |
| `QuestObjective` | Resource (base) | Un objetivo evaluable por señales |
| `QuestReward` | Resource | Recompensa componible |
| `QuestSystem` | system | Rastrea misiones, escucha señales, entrega recompensas |
| `QuestLog` | data/ui | Estado y presentación del diario de misiones |

## 8. Señales (EventBus)

- `quest_offered(quest)` / `quest_accepted(quest)`
- `quest_objective_updated(quest, objective)`
- `quest_completed(quest)` / `quest_failed(quest)`

## 9. Preguntas abiertas

- 🔴 ¿Cuánto hilo narrativo principal en v1.0 vs. dejarlo casi sandbox? (Ver [Lore](../Lore.md) abiertos.)
- 🔴 ¿Los encargos fallidos penalizan reputación siempre, o solo los aceptados explícitamente?
- 🟡 Set de misiones de tutorial para el onboarding (Fase 7).
