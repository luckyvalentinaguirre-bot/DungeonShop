# 13 — Controles e Input

> Esquema de control y accesibilidad. Objetivo: **mouse+teclado primero**, con
> paridad de **mando** para Steam Deck. Las acciones se declaran en `project.godot`
> (input map) y se referencian por nombre, nunca por tecla fija. Estados: 🟢/🟡/🔴.

---

## 1. Principios

- Toda interacción usa **acciones nombradas** del input map, no teclas literales →
  remapeo y soporte de mando gratis.
- **Cozy = pocos botones.** Interacción principalmente con **puntero** (ratón / stick
  o táctil), no combos.
- **Accesible:** remapeable, con opciones de tamaño de texto y velocidad de
  *typewriter* de diálogo (ver [Dialogue](10_Dialogue.md)).

## 2. Acciones (input map) 🟡

| Acción | Ratón/Teclado | Mando | Uso |
|--------|---------------|-------|-----|
| `ui_interact` | Clic izq. | A / Cruz | Interactuar, confirmar, arrastrar |
| `ui_cancel` | Clic der. / Esc | B / Círculo | Cancelar, volver |
| `pause_game` | Esc | Start | Menú de pausa |
| `quick_save` | F5 | — | Guardado rápido |
| navegación UI | Ratón / flechas | D-pad / stick | Moverse por menús |

(Se ampliará al construir la UI en Fase 7. Declaradas mínimas en `project.godot`.)

## 3. Soporte de mando / Steam Deck

- Toda la UI navegable con D-pad/stick (focus visible).
- Objetivos táctiles/de foco de tamaño cómodo.
- Probar en resolución y controles de Steam Deck antes de release.

## 4. Preguntas abiertas

- 🔴 ¿Arrastrar y soltar con mando cómo se resuelve (modo "coger/soltar" con A)?
  Afecta a [Inventory](09_Inventory.md).
- 🟡 Set final de acciones y bindings por defecto (Fase 7).
