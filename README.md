# Dungeon Shop

> No eres el héroe. Eres quien lo equipa.

**Dungeon Shop** es un juego *cozy* de gestión de tienda ambientado en un reino
medieval de fantasía. El jugador administra una tienda donde los aventureros
compran armas, armaduras, pociones, herramientas y objetos mágicos antes de
partir a las mazmorras. Mientras los héroes viven sus aventuras fuera de cámara,
tú fabricas, fijas precios, negocias, mejoras el local y construyes la tienda
más importante del reino.

- **Motor:** Godot 4.x
- **Lenguaje:** GDScript
- **Plataforma objetivo:** PC (Steam), con vista a Steam Deck
- **Estilo:** *cozy*, pixel-art/2D con identidad propia
- **Referencias tonales:** Moonlighter, Potion Craft, Stardew Valley, Dave the Diver
  (referencias, **no** plantillas a copiar)

---

## Estado del proyecto

Estamos en **desarrollo por fases**. No se avanza de fase hasta cerrar la anterior.

| Fase | Nombre | Estado |
|------|--------|--------|
| 1 | Arquitectura completa | ✅ Completada |
| 2 | Diseño del mundo | ✅ Completada |
| 3 | Sistema de economía | ✅ Completada (primer código + tests) |
| 4 | Clientes | ✅ Completada (modelo híbrido + tests) |
| 5 | Objetos | ✅ Completada (inventario + catálogo + tests) |
| 6 | Fabricación | ✅ Completada (rasgos de material + tests) |
| 7 | Interfaz | 🟡 En progreso (¡primera versión jugable!) |
| 8 | Guardado | ⬜ Pendiente |
| 9 | Pulido | ⬜ Pendiente |

> **Fases 1–2 = documentación + esqueleto de carpetas + biblia de mundo.**
> Todavía **no** se escribe lógica de juego (empieza en Fase 3). Ver `docs/Roadmap.md`.

---

## Cómo está organizado el repo

Este repositorio contiene el proyecto de Godot en su raíz. Toda la estructura y las
convenciones están explicadas en:

- **[docs/](docs/)** — Todo el diseño del juego y la arquitectura técnica.
  Empieza por [`docs/README.md`](docs/README.md).
- **[docs/GameDesignDocument.md](docs/GameDesignDocument.md)** — El GDD, punto de entrada al diseño.
- **[docs/systems/00_Architecture.md](docs/systems/00_Architecture.md)** — Arquitectura técnica (SOLID, composición, capas).

## Árbol de carpetas

Ver [`docs/systems/00_Architecture.md`](docs/systems/00_Architecture.md#estructura-de-carpetas)
para la explicación de cada carpeta y qué debe (y qué no debe) contener.
