# Roadmap — Plan de desarrollo por fases

> Regla de oro: **no se avanza de fase hasta cerrar la anterior.** Cada fase tiene
> criterios de "hecho" (DoD) verificables. La Fase 1 es 100% documentación y
> esqueleto; el código de juego empieza en la Fase 3.

---

## Fase 1 — Arquitectura completa ✅ (completada)

**Objetivo:** dejar todo el diseño y la estructura listos antes de programar.

**Entregables:**
- [x] Árbol de carpetas completo (`assets/`, `scripts/`, `scenes/`, `resources/`, …).
- [x] `project.godot` con autoloads, display, input e i18n base.
- [x] `.gitignore` de Godot.
- [x] Game Design Document ([GameDesignDocument.md](GameDesignDocument.md)).
- [x] Historia y lore ([Lore.md](Lore.md)).
- [x] Documento de arquitectura técnica ([systems/00_Architecture.md](systems/00_Architecture.md)).
- [x] Docs de los 13 sistemas (economía, clientes, héroes, reputación, fabricación,
      progresión, eventos, guardado, inventario, diálogo, misiones, logros, controles).
- [x] Dirección de arte y audio.
- [x] Catálogos de contenido inicial (items, NPCs).

**Definition of Done:** un desarrollador nuevo puede leer `docs/` y entender qué se
va a construir, cómo se organiza el código, y qué preguntas siguen abiertas. Ningún
sistema de juego implementado todavía.

---

## Fase 2 — Diseño del mundo ✅ (completada)

**Objetivo:** cerrar el contenido narrativo y de mundo.
- [x] Cerrar preguntas 🔴 de [Lore](Lore.md): antecesor = **abuela Rilda Yunque**
      (maestra artesana desaparecida en las Grietas); peso narrativo = **sandbox con
      hilo opcional**; nombres firmes (Válderin / Rincón de Yunque / familia Yunque).
- [x] Facciones enfrentadas definidas ([Reputation](systems/04_Reputation.md) §5):
      Corona⚔Buhoneros, Arcano⚔Corona, Gremio⚔Artesanos (roce suave).
- [x] Elenco definitivo de NPCs con arcos, héroes y caras de facción ([NPCs](NPCs.md)).
- [x] Mapa del reino, atmósfera y orden de desbloqueo de localizaciones
      ([WorldBible](WorldBible.md)).
- [x] **Biblia de mundo** completa: historia/timeline, cultura, calendario y
      estructura del arco opcional de la abuela ([WorldBible.md](WorldBible.md)).
- **DoD:** ✅ biblia de mundo/narrativa aprobada; sin 🔴 críticos de mundo (solo
  quedan 🔴 de dosificación del misterio, reservados a Fase 7/9 por diseño).

---

## Fase 3 — Sistema de economía ✅ (completada)

**Objetivo:** primer código de juego. Motor económico funcional y testeado.
- [x] Implementados `EconomyConfig`, `PriceCalculator`, `DemandModel`, `MarketSystem`,
      `TransactionResolver`, `WalletComponent` y la fachada `EconomySystem`
      (ver [systems/01](systems/01_Economy.md)). Más datos mínimos `ItemData`/`ItemInstance`
      y autoloads `EventBus`/`GameConfig`.
- [x] Tests unitarios de precios/transacciones/demanda/mercado/cartera. **Nota:** se
      usa un runner propio sin dependencias (`tests/run_tests.gd`) en vez de GUT, para
      no requerir addons todavía; es migrable a GUT más adelante.
- [x] Escena de demo sin UI para inspeccionar la economía (`scenes/dev/DevRoot.tscn`).
- **Decisiones cerradas:** regateo automático por ánimo; demanda global por categoría.
- **DoD:** ✅ se vende un objeto y se consulta el precio de material con precios
  dinámicos desde una escena de prueba, todo cubierto por tests. Sin UI.

### Cómo probarlo (en tu máquina, con Godot 4.3+)
```bash
# Ejecutar la demo (imprime un escenario económico por consola):
godot --headless --path . res://scenes/dev/DevRoot.tscn
# Ejecutar los tests (sale con código 0 si todo pasa):
godot --headless --path . --script res://tests/run_tests.gd
```
O abre el proyecto en el editor de Godot y pulsa **F5**.

---

## Fase 4 — Clientes ✅ (completada)

- [x] `CustomerData`, `CustomerNeed`, `Customer`, `CustomerSpawner`,
      `CustomerController`, `HaggleResolver`, `MoodComponent`, `ShopQueue`,
      `ShelfPurchaseResolver` (ver [systems/02](systems/02_Customers.md)).
- [x] Negociación resuelta: automática por ánimo (`HaggleResolver`).
- [x] Modelo de atención **híbrido**: cola de mostrador (con regateo) + autoservicio
      de estantería. La estantería opera sobre una lista de productos (se conecta al
      inventario real en Fase 5).
- [x] 6 archivos de tests nuevos; demo de jornada en `scenes/dev/ShopDayDemo.tscn`.
- **DoD:** ✅ los clientes llegan, piden y compran contra el motor económico, por las
  dos vías, todo testeado. Sin UI.

### Cómo probarlo (Godot 4.3+)
```bash
godot --headless --path . res://scenes/dev/ShopDayDemo.tscn   # simula una jornada
godot --headless --path . --script res://tests/run_tests.gd   # todos los tests
```

---

## Fase 5 — Objetos ✅ (completada)

- [x] `ItemData` (ampliado con `tags`), `ItemInstance`, catálogo semilla como
      Resources en `resources/items/` + `ItemDatabase` que lo carga ([Items](Items.md)).
- [x] Sistema de inventario ([systems/09](systems/09_Inventory.md)): `Inventory`
      (apilado, capacidad, mover) e `InventoryComponent`.
- [x] Estantería del autoservicio conectada a un `Inventory` real (descuenta stock).
- [x] 2 archivos de tests nuevos (inventario, catálogo).
- **DoD:** ✅ objetos definidos como Resources, almacenables y vendibles, testeado.

### Cómo probarlo (Godot 4.3+)
```bash
godot --headless --path . res://scenes/dev/ShopDayDemo.tscn   # jornada con estantería real
godot --headless --path . --script res://tests/run_tests.gd   # todos los tests
```

---

## Fase 6 — Fabricación ✅ (completada)

- [x] `RecipeData`, `MaterialTrait`, `CraftingStationData`, `CraftingResolver`,
      `QualityCalculator` ([systems/05](systems/05_Crafting.md)).
- [x] Rasgos de material combinados en un perfil de atributos + calidad/defectos.
- [x] Contenido semilla como Resources (rasgos, materiales, receta, estación).
- [x] 2 archivos de tests nuevos; demo en `scenes/dev/CraftingDemo.tscn`.
- **Decisiones cerradas:** recetas con materiales variables (no libre); fabricación
  instantánea en v1.0.
- **DoD:** ✅ se fabrica un objeto combinando materiales con rasgos, y la misma receta
  da perfiles distintos; testeado.

### Cómo probarlo (Godot 4.3+)
```bash
godot --headless --path . res://scenes/dev/CraftingDemo.tscn   # fabricación con perfiles
godot --headless --path . --script res://tests/run_tests.gd    # todos los tests
```

---

## Fase 7 — Interfaz 🟡 (en progreso)

Se construye por incrementos jugables. La UI se genera por código (escenas `.tscn`
mínimas + scripts de pantalla), robusta y convertible a escenas de editor para pulir.

**Incremento 1 — Primera versión JUGABLE ✅**
- [x] Autoloads `GameState` (estado de partida: oro, jornada, economía, stock,
      clientela) y `SceneRouter` (cambio de escena).
- [x] `MainMenu` (nueva partida / salir) y `ShopScreen` (HUD + mostrador + stock + log).
- [x] Bucle central jugable con ratón: atender clientes (mostrador con regateo por
      precio ±, y autoservicio de estantería), vender del stock, avanzar jornada.
- [x] `UiFactory` (widgets con estilo cozy por código).

**Incremento 2 — Panel de fabricación ✅**
- [x] `CraftingLibrary` (carga recetas y estaciones de `resources/`).
- [x] `GameState.craft()` (fabrica, consume materiales del stock, añade el resultado).
- [x] `CraftingScreen`: elige receta + materiales del stock y fabrica; muestra en vivo
      calidad, defecto y perfil según los materiales. Accesible desde la tienda.

**Incremento 3 — Personajes 2D animados + habilidades ✅**
- [x] `CharacterView`: personaje 2D con sprite (placeholder SVG) y animaciones por
      código (entrar, respirar, alegrarse, enfadarse). El cliente aparece en el
      mostrador y reacciona a la venta. Arte final = sustituir los SVG.
- [x] `PlayerSkills` (aprender haciendo): la herrería sube al fabricar, mejora la
      calidad y reduce defectos; las recetas pueden exigir un nivel mínimo.
- [x] Integrado en `GameState.craft()` y en `CraftingScreen` (nivel, requisito,
      subida de nivel); tests de habilidades y de fabricación con habilidad.

**Incremento 4 — TODOS los sistemas (lógica) ✅**
Implementados como sistemas puros y testeables, integrados en `GameState` (y en la
tienda donde aplica), según la [Visión del juego](GameVision.md):
- [x] Reputación (`ReputationSystem`, con tensiones) — integrada en las ventas.
- [x] Mercado de compra de materiales (`GameState.buy_material`).
- [x] Héroes y expediciones (`ExpeditionResolver`, `HeroManager`).
- [x] Eventos del reino / "jefes" (`EventEngine`, `EventData`, `EventEffect`).
- [x] Misiones y logros (`QuestSystem`, `AchievementSystem`) — con recompensas.
- [x] Diálogos (`DialogueRunner`, motor propio).
- [x] Guardado/carga (`SaveManager`, `GameState.capture/restore`).
- [x] Distribución de tienda cenital (`ShopLayout`: colocar estantes + asignar producto).
- [x] Empleados (`EmployeeManager`), exploración/regiones (`ExplorationSystem`),
      investigación (`ResearchSystem`), decoración (`DecorationData`).
- [x] ~35 archivos de tests en total.

**Pendiente — capa VISUAL (siguiente gran bloque):**
- [ ] Render de la tienda en **vista cenital (top-down)** desde `ShopLayout`.
- [ ] UIs de mercado, empleados, exploración, investigación, misiones/logros, diálogo.
- [ ] Inventario con arrastrar-soltar; input map final y mando.
- [ ] Arte y animación finales (sustituir placeholders).
- **DoD:** el bucle central ya es jugable con ratón; se amplía con la vista cenital
  y las pantallas de cada sistema.

### Cómo probarlo (Godot 4.3+)
Abre el proyecto en el editor y pulsa **F5** (la escena principal es el menú), o:
```bash
godot --path .            # ejecuta el juego (menú → nueva partida → tienda)
godot --headless --path . --script res://tests/run_tests.gd   # tests de la lógica
```

---

## Fase 8 — Guardado

- `SaveManager`, serialización, autosave, versionado, migraciones
  ([systems/08](systems/08_Save.md)).
- Preparar compatibilidad con Steam Cloud.
- **DoD:** guardar/cargar cualquier estado de partida de forma robusta; tests de
  ida y vuelta.

---

## Fase 9 — Pulido

- Reputación, héroes, eventos y logros completos e integrados.
- Arte y audio finales, *juice*, accesibilidad, localización.
- Balance con playtesting; preparación de build de Steam.
- **DoD:** experiencia completa, estable y pulida, lista para publicar.

---

## Reglas de proceso

- Cada fase abre cerrando los 🔴 relevantes del/los documento(s) de su sistema.
- Nada entra si no refuerza un pilar del GDD (§2) — control de *feature creep*.
- El código sigue [systems/00_Architecture.md](systems/00_Architecture.md): scripts
  < 200 líneas, composición, datos en Resources, testeable sin UI, documentado.
