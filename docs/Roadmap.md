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

## Fase 5 — Objetos

- `ItemData`, `ItemInstance`, taxonomía y catálogo inicial ([Items](Items.md)).
- Sistema de inventario ([systems/09](systems/09_Inventory.md)): `Inventory`,
  `InventoryComponent`.
- **DoD:** objetos definidos como Resources, almacenables y vendibles; testeado.

---

## Fase 6 — Fabricación

- `RecipeData`, `MaterialTrait`, estaciones, `CraftingResolver`,
  `QualityCalculator` ([systems/05](systems/05_Crafting.md)).
- Rasgos de material y calidad/defectos.
- **DoD:** se fabrica un objeto combinando materiales con rasgos; testeado.

---

## Fase 7 — Interfaz

- Escenas y UI de tienda, mostrador, inventario, fabricación, mercado, diálogo, HUD.
- Sistema de diálogo ([systems/10](systems/10_Dialogue.md)) y misiones/tutorial
  ([systems/11](systems/11_Quests.md)).
- Input map final y soporte de mando ([systems/13](systems/13_Controls.md)).
- **DoD:** el bucle central es jugable con ratón de principio a fin.

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
