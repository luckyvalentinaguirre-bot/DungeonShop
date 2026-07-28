# 03 — Sistema de Héroes

> Los héroes son NPCs con vida propia que compran en tu tienda y **parten a la
> mazmorra fuera de cámara**. Su suerte depende de lo que les vendiste. Es el
> sistema que da alma narrativa al juego. Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- El jugador **nunca controla** al héroe ni ve el combate (regla de canon, ver
  [Lore](../Lore.md)).
- El equipo vendido debe tener **consecuencias legibles** en la expedición.
- Crear **vínculo**: héroes con nombre, personalidad, y arcos de lealtad.
- Que volver de la mazmorra **alimente el bucle** (botín, rumores, encargos).

## 2. El héroe como extensión de cliente

Un héroe es un `Customer` + `HeroProfile` (composición). Compra como cualquier
cliente, pero además tiene un ciclo de **expedición**.

`HeroProfile` (Resource) contiene: nombre, clase/profesión (ver
[professions](../../resources/professions)), nivel, rasgos de personalidad,
lealtad hacia la tienda, y su equipo actual (lo que te compró).

## 3. Ciclo de vida del héroe

```
En el pueblo → visita la tienda → se equipa (compra/encarga) →
  parte a una expedición (Las Grietas) → [resolución fuera de cámara] →
  regresa (o no) → reporta resultado → botín/rumores/lealtad → descansa → repite
```

## 4. Resolución de la expedición (fuera de cámara) 🟡

Cuando un héroe parte, `ExpeditionResolver` calcula el resultado **sin simular
combate en pantalla**. Entradas:

- **Poder del equipo** que le vendiste (calidad + adecuación de armas/armaduras/
  pociones/herramientas al reto).
- **Dificultad de la mazmorra/piso** objetivo.
- **Rasgos y nivel** del héroe.
- **Azar acotado** (RNG con semilla, nunca resultado puramente aleatorio injusto).

Salidas posibles (gradiente, no binario):
- **Triunfo:** vuelve con buen botín, sube lealtad y nivel.
- **Éxito ajustado:** vuelve herido; la poción que le vendiste "le salvó la vida".
- **Fracaso/retirada:** vuelve sin botín, molesto o agradecido según equipo.
- **Baja (rara):** no vuelve. Significativa, siempre ligada a equipo insuficiente;
  nunca gratuita (ver canon en [Lore](../Lore.md)).

El resultado se **narra** (texto/diálogo), reforzando el vínculo causa→efecto.

## 5. Consecuencias para la tienda

- **Botín:** el héroe puede vender/regalar objetos de mazmorra → materiales raros
  para fabricar, o piezas para revender.
- **Rumores:** desbloquean encargos, eventos, o pistas del arco principal
  (ver [Quests](11_Quests.md), [Events](07_Events.md)).
- **Lealtad:** héroes leales vuelven, pagan mejor, te recomiendan (reputación) y
  desbloquean su arco personal.
- **Reputación de facción:** equipar bien a héroes del Gremio sube esa facción.

## 6. Adecuación del equipo (por qué importa vender bien)

`ExpeditionResolver` no mira solo "poder total": mira **adecuación**.
- Un mago con armadura pesada rinde peor.
- Sin pociones, una expedición larga acaba en retirada.
- Herramientas correctas (ganzúas, cuerdas, antorchas) abren mejores resultados.

Esto empuja al jugador a **conocer a sus héroes** y venderles lo adecuado, no lo
más caro. Refuerza el pilar "la tienda es la protagonista".

## 7. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `HeroProfile` | Resource | Datos del héroe (clase, nivel, rasgos, lealtad, equipo) |
| `ProfessionData` | Resource | Definición de clase (mago, guerrero, pícaro…) y afinidades |
| `ExpeditionData` | Resource | Un reto/mazmorra objetivo y su dificultad |
| `ExpeditionResolver` | system (puro) | Calcula resultado a partir de equipo + reto + azar |
| `ExpeditionOutcome` | data | Resultado estructurado (botín, heridas, lealtad, narrativa) |
| `HeroManager` | system | Rastrea héroes del reino, sus estados y ciclos |
| `HeroView` | ui | Ficha/retrato del héroe |

`ExpeditionResolver` es **puro y testeable**: dado el mismo input y semilla, mismo
output. Clave para poder balancear y testear.

## 8. Señales (EventBus)

- `hero_departed(hero, expedition)`
- `hero_returned(hero, outcome: ExpeditionOutcome)`
- `hero_loyalty_changed(hero, delta)`
- `hero_lost(hero)` (evento raro y narrativamente pesado)

## 9. Preguntas abiertas

- 🔴 ¿La expedición se resuelve al instante al partir, o tarda N jornadas (héroe
  "fuera")? Lo segundo da mejor ritmo y anticipación. Recomendado: N jornadas.
- 🔴 ¿El jugador ve una "previsión de riesgo" antes de que el héroe parta (para
  decidir qué venderle) o es opaco? Afecta a legibilidad de consecuencias.
- 🟡 Número de héroes con arco en v1.0 (~6, ver GDD scope).
