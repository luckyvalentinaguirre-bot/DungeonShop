# Game Design Document — Dungeon Shop

> Documento vivo. Versión 0.1 (Fase 1). Toda regla marcada 🟡/🔴 puede cambiar
> hasta que su sistema entre en su fase de implementación.

---

## 1. Visión en una frase

> **Eres el tendero que arma a los héroes del reino.** Fabricas, negocias y haces
> crecer tu tienda; los héroes se van a la mazmorra y vuelven (o no) con historias,
> botín y necesidades nuevas.

## 2. Pilares de diseño

Todo el diseño se juzga contra estos cuatro pilares. Si una mecánica no refuerza
al menos uno, se corta.

1. **Cozy, no estresante.** El tiempo lo controla el jugador. No hay *game over*
   por quedarse quieto. La presión viene de la ambición, no del castigo. Nada de
   temporizadores agresivos estilo arcade.
2. **La tienda es la protagonista.** Cada sistema debe hacer que administrar la
   tienda se sienta vivo: fabricar, exhibir, fijar precios, decorar, atender.
3. **Historias que ocurren fuera de cámara.** Los héroes son NPCs con vidas
   propias. El jugador siente su aventura por lo que compran, lo que cuentan y
   lo que traen de vuelta — nunca los controla.
4. **Profundidad por capas.** Fácil de empezar (vender una espada), profundo al
   dominar (cadenas de fabricación, economía, reputación, especialización).

## 3. Público objetivo

- Jugadores de *cozy management / tycoon* (Stardew Valley, Moonlighter, Potion
  Craft, Dave the Diver, Recettear, Spiritfarer).
- Sesiones de 20–90 min; disfrutan optimizar sistemas sin presión de reflejos.
- PC (mouse + teclado primero), diseño compatible con Steam Deck (mando).

## 4. Diferenciación

No copiamos ninguna referencia. Nuestra identidad:

- **El vínculo tendero↔héroe:** los héroes recuerdan lo que les vendiste. Una
  poción que les salvó la vida sube su lealtad; una armadura defectuosa puede
  matarlos. Sus destinos son consecuencia de tus decisiones comerciales.
- **Fabricación con *personalidad de material*:** los materiales tienen rasgos
  (ver [Crafting](systems/05_Crafting.md)) que empujan al jugador a experimentar,
  no a seguir recetas óptimas fijas.
- **Reputación como moneda social**, separada del dinero, que abre facciones,
  proveedores y clientela de élite.

## 5. Bucle de juego (game loops)

### 5.1 Bucle central (minuto a minuto)
```
Abrir tienda → Llega cliente → Diálogo/petición → Negociar venta o fabricar a pedido
   → Cobrar (oro + reputación) → Reponer/organizar estantería → Siguiente cliente
```

### 5.2 Bucle de jornada (una "jornada" = unidad de tiempo del juego)
```
Mañana:  planificar (revisar stock, precios, encargos, mercado)
Día:     atender clientes (bucle central) y/o fabricar
Tarde:   héroes regresan de mazmorra → traen botín, rumores, encargos
Noche:   cerrar caja, comprar materiales, mejorar tienda, guardar
```

### 5.3 Bucle de progresión (largo plazo)
```
Ganar oro + reputación → desbloquear recetas, estaciones, ampliaciones, empleados,
   proveedores y barrios del reino → acceder a clientela y materiales mejores →
   metas de negocio más grandes → repetir a mayor escala
```

Detalle en [Progression](systems/06_Progression.md).

## 6. Mecánicas principales (resumen; cada una tiene su doc de sistema)

| Mecánica | Qué hace el jugador | Doc |
|----------|---------------------|-----|
| **Venta / atención** | Recibe clientes, lee su petición, ofrece producto, fija precio, negocia | [Customers](systems/02_Customers.md) |
| **Economía / precios** | Compra materiales, fija precios, gestiona oferta/demanda y caja | [Economy](systems/01_Economy.md) |
| **Fabricación** | Combina materiales en estaciones para crear objetos | [Crafting](systems/05_Crafting.md) |
| **Inventario / stock** | Organiza almacén y estantería, reposición | [Inventory](systems/09_Inventory.md) |
| **Reputación** | Sube prestigio de la tienda; desbloquea facciones/clientela | [Reputation](systems/04_Reputation.md) |
| **Héroes** | Ve partir/volver héroes; su suerte depende de lo vendido | [Heroes](systems/03_Heroes.md) |
| **Progresión** | Mejora tienda, desbloquea recetas/estaciones/barrios | [Progression](systems/06_Progression.md) |
| **Eventos** | Reacciona a sucesos del reino (festivales, guerras, plagas) | [Events](systems/07_Events.md) |
| **Misiones** | Objetivos guiados y encargos especiales | [Quests](systems/11_Quests.md) |
| **Diálogo** | Conversa con clientes/vecinos, decide respuestas | [Dialogue](systems/10_Dialogue.md) |
| **Logros** | Metas coleccionables (Steam achievements) | [Achievements](systems/12_Achievements.md) |

## 7. Estructura del tiempo de juego 🟡

- La unidad base es la **jornada** (un "día" de tienda). No hay reloj de segundos:
  el jugador avanza por **fases de la jornada** (mañana/día/tarde/noche) cuando
  decide, pulsando "avanzar".
- Un conjunto de jornadas forma una **semana**; las semanas marcan el ciclo del
  **mercado** (precios de materiales fluctúan) y de **eventos**.
- Estaciones/festivales del reino dan variedad de mediano plazo.
- 🔴 **Abierto:** ¿los clientes tienen un límite por jornada, o el jugador cierra
  la tienda cuando quiere? Decidir antes de Fase 4.

## 8. Condiciones de victoria / final 🟡

Juego *sandbox* con **metas de negocio** en vez de un final duro:

- Serie de hitos ("Tienda de bronce → plata → oro → legendaria del reino").
- Al alcanzar la meta legendaria se desbloquea un **modo libre + epílogo** narrativo.
- Sin *game over*. La quiebra es posible pero se recupera (préstamos, ver
  [Economy](systems/01_Economy.md)); nunca borra la partida.

## 9. Estética y tono

Ver [ArtDirection.md](ArtDirection.md) y [AudioDirection.md](AudioDirection.md).
Resumen: cálido, artesanal, humor amable, personajes entrañables. La violencia de
las mazmorras se cuenta, no se muestra.

## 10. Alcance (scope) y anti-alcance

**Dentro del alcance v1.0:**
- Un reino con ~4–6 barrios/localizaciones.
- ~6 estaciones de fabricación, ~80–120 objetos, ~8 recetas base ampliables.
- ~20 clientes recurrentes con arco propio + clientela genérica.
- ~6 héroes con arcos narrativos.
- Sistemas: economía, fabricación, reputación, eventos, misiones, guardado,
  logros, diálogo.

**Fuera del alcance v1.0 (posibles DLC/actualizaciones):**
- Multijugador.
- Control directo de héroes o combate jugable en mazmorra.
- Mundo abierto explorable a pie fuera del pueblo.
- Modding pesado (se deja la puerta abierta con datos en Resources, pero sin API pública).

## 11. Riesgos de diseño

| Riesgo | Mitigación |
|--------|-----------|
| Economía se rompe (inflación/deflación) | Modelo económico parametrizado en Resources; ver [Economy](systems/01_Economy.md) |
| Bucle se vuelve repetitivo | Eventos + arcos de héroes + metas escaladas rompen la rutina |
| *Feature creep* | Fases estrictas; nada entra si no refuerza un pilar |
| Fabricación demasiado óptima/soluble | Rasgos de material + variación de mercado mantienen decisiones vivas |

## 12. Glosario

- **Jornada:** unidad de tiempo (un día de tienda).
- **Encargo (commission):** pedido específico de un cliente/héroe a fabricar.
- **Rasgo de material:** propiedad que un material aporta al objeto fabricado.
- **Facción:** grupo del reino (Gremio de Aventureros, Corona, Arcanistas, etc.).
- **Prestigio:** nombre corto de la reputación agregada de la tienda.
