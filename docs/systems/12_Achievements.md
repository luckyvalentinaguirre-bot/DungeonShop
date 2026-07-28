# 12 — Sistema de Logros

> Metas coleccionables que reconocen hitos del jugador. Pensadas para integrarse con
> **Steam Achievements** de cara a la publicación. Sistema hermano de
> [Quests](11_Quests.md) pero **meta** (sin recompensa de juego, sin caducidad).
> Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- Reconocer logros de forma **satisfactoria y variada** (progreso, maestría, secretos).
- **Desacoplado:** el sistema escucha señales; los sistemas de juego no saben de logros.
- **Portable a Steam:** cada logro mapea a un ID de Steam; el sistema funciona igual
  con o sin Steam (capa de plataforma detrás de una interfaz).

## 2. Categorías de logro 🟡

| Categoría | Ejemplo |
|-----------|---------|
| **Progreso** | Alcanzar la Tienda Legendaria |
| **Acumulación** | Vender 1000 objetos; ganar 100 000 coronas |
| **Maestría** | Fabricar un objeto de calidad máxima; cero defectos en 50 forjas |
| **Relación** | Máxima lealtad con un héroe; salvar a un héroe con una poción |
| **Facción** | Máxima afinidad con cada facción |
| **Secreto** | Descubrir el destino del antecesor (narrativa) |

## 3. Cómo se otorgan (desacoplado)

`AchievementSystem` escucha el `EventBus` (las mismas señales que Quests) y lleva
**contadores/flags** persistentes. Cuando un logro cumple su condición, se marca y se
notifica a la capa de plataforma. Un logro nuevo = un `AchievementData` + una
condición componible; sin tocar el motor ni los sistemas de juego.

## 4. Persistencia

- El **progreso de logros** se guarda **global al jugador** (no por slot), como los
  ajustes → un logro conseguido en cualquier partida cuenta. Ver [Save](08_Save.md).
- Con Steam activo, la fuente de verdad es Steam; local es respaldo/offline.

## 5. Capa de plataforma (portabilidad)

Interfaz `IAchievementBackend` con dos implementaciones:
- `LocalAchievementBackend` (archivo local; dev y builds sin Steam).
- `SteamAchievementBackend` (vía integración Steam, ver §7).

El `AchievementSystem` depende de la **interfaz**, no de Steam (inversión de
dependencias). Cambiar de backend no toca la lógica de logros.

## 6. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `AchievementData` | Resource | Definición (id, id_steam, condición, oculto) |
| `AchievementCondition` | Resource (base) | Condición evaluable por señales/contadores |
| `AchievementSystem` | system | Rastrea progreso, dispara desbloqueos |
| `IAchievementBackend` | interfaz | Contrato de plataforma |
| `Local/SteamAchievementBackend` | system | Implementaciones |

## 7. Integración Steam 🟡

- Requiere la librería de Steam para Godot (GodotSteam) en `addons/`, se añade en la
  fase de publicación (post v1.0 de contenido).
- Diseñar los IDs de logro y sus condiciones **desde ya** para no rehacer después.

## 8. Señales (EventBus)

- `achievement_unlocked(achievement)`
- `achievement_progress(achievement, current, target)` (para logros de acumulación)

## 9. Preguntas abiertas

- 🔴 Lista definitiva de logros (afecta a marketing/Steam) — cerrar cerca de release.
- 🟡 ¿Mostrar progreso de logros de acumulación en la UI o solo al desbloquear?
