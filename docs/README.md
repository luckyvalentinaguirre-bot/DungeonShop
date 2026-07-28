# Documentación de Dungeon Shop

Este directorio contiene **todo el diseño** del juego antes de escribir código de
juego. La regla es simple: *si un sistema no está documentado aquí, no se programa*.

## Cómo leer esta documentación

Lee en este orden si eres nuevo en el proyecto:

1. [`GameDesignDocument.md`](GameDesignDocument.md) — Visión, pilares, bucle de juego. **Empieza aquí.**
2. [`Lore.md`](Lore.md) — Historia del mundo, ambientación y tono narrativo.
3. [`systems/00_Architecture.md`](systems/00_Architecture.md) — Cómo se organiza el código (SOLID, composición, capas).
4. Los documentos de sistema individuales en [`systems/`](systems/).

## Índice de documentos de diseño (visión general)

| Documento | Qué cubre |
|-----------|-----------|
| [GameDesignDocument.md](GameDesignDocument.md) | Visión, pilares, bucle central, público objetivo, alcance |
| [Lore.md](Lore.md) | Resumen de historia, geografía, facciones y tono (decisiones cerradas) |
| [WorldBible.md](WorldBible.md) | **Biblia de mundo (Fase 2):** timeline, mapa, facciones, tensiones, cultura, calendario, arco de la abuela |
| [Economy.md](Economy.md) | Resumen económico de alto nivel (números, monedas) |
| [Items.md](Items.md) | Catálogo y taxonomía de objetos |
| [NPCs.md](NPCs.md) | Elenco de personajes (clientes, héroes, vecinos) |
| [Progression.md](Progression.md) | Curva de progresión del jugador |
| [Roadmap.md](Roadmap.md) | Plan de las 9 fases y criterios de "hecho" |
| [ArtDirection.md](ArtDirection.md) | Dirección de arte *cozy*, paleta, identidad visual |
| [AudioDirection.md](AudioDirection.md) | Dirección de música y sonido |

## Índice de documentos de sistema (diseño técnico + reglas)

Cada sistema tiene un documento que define **reglas de diseño**, **datos**,
**responsabilidades de clases** y **cómo se compone** con el resto. Están numerados
por dependencia aproximada.

| # | Sistema | Documento |
|---|---------|-----------|
| 00 | Arquitectura | [systems/00_Architecture.md](systems/00_Architecture.md) |
| 01 | Economía | [systems/01_Economy.md](systems/01_Economy.md) |
| 02 | Clientes | [systems/02_Customers.md](systems/02_Customers.md) |
| 03 | Héroes | [systems/03_Heroes.md](systems/03_Heroes.md) |
| 04 | Reputación | [systems/04_Reputation.md](systems/04_Reputation.md) |
| 05 | Fabricación | [systems/05_Crafting.md](systems/05_Crafting.md) |
| 06 | Progresión | [systems/06_Progression.md](systems/06_Progression.md) |
| 07 | Eventos | [systems/07_Events.md](systems/07_Events.md) |
| 08 | Guardado | [systems/08_Save.md](systems/08_Save.md) |
| 09 | Inventario | [systems/09_Inventory.md](systems/09_Inventory.md) |
| 10 | Diálogos | [systems/10_Dialogue.md](systems/10_Dialogue.md) |
| 11 | Misiones | [systems/11_Quests.md](systems/11_Quests.md) |
| 12 | Logros | [systems/12_Achievements.md](systems/12_Achievements.md) |
| 13 | Controles | [systems/13_Controls.md](systems/13_Controls.md) |

## Convenciones del documento

- **🟢 Decidido** — regla firme, se implementa tal cual.
- **🟡 Provisional** — dirección elegida, puede ajustarse con playtesting.
- **🔴 Abierto** — pregunta sin resolver, requiere decisión antes de programar el sistema.

Cada documento de sistema termina con una sección **"Preguntas abiertas"** que
lista los 🔴 pendientes.
