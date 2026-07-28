# 07 — Sistema de Eventos

> Sucesos del reino que rompen la rutina: festivales, guerras, plagas, visitas,
> crisis de mercado. Dan variedad de mediano plazo y conectan economía, clientela y
> narrativa. Data-driven y extensible. Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- Romper la repetición del bucle (riesgo del GDD §11).
- Crear **picos de oportunidad y decisión** (una guerra dispara la demanda de armas).
- Contenido nuevo = **un `EventData.tres`**, sin tocar el motor (Abierto/Cerrado).

## 2. Anatomía de un evento (`EventData`)

Un evento es un `Resource` con:
- **Disparador (trigger):** cuándo puede ocurrir (semana, rango, facción, rumor de
  héroe, azar…).
- **Duración:** puntual o de varias jornadas.
- **Efectos:** modificadores aplicados mientras está activo (ver §4).
- **Presentación:** texto/diálogo y opciones para el jugador (si es interactivo).

## 3. Tipos de evento 🟡

| Tipo | Ejemplo | Efecto principal |
|------|---------|------------------|
| **Económico** | Escasez de hierro | Sube precio de material, sube valor de armas |
| **De demanda** | Guerra fronteriza | ↑ demanda de armas/armaduras/pociones |
| **Festival** | Feria del reino | ↑ clientela y demanda de lujo; decoración temática |
| **Crisis** | Plaga | ↑ demanda de pociones; riesgo para héroes |
| **Social/facción** | Visita de un noble | Oportunidad de reputación con la Corona |
| **Narrativo** | Pista de la Fractura | Avanza el arco principal (ver [Quests](11_Quests.md)) |

## 4. Efectos componibles (`EventEffect`)

Los efectos son **componentes de datos** que el motor aplica/retira sin conocer su
tipo concreto (polimorfismo por composición):

- `DemandModifierEffect` (sesga demanda de una categoría)
- `PriceModifierEffect` (materiales u objetos)
- `SpawnModifierEffect` (más/menos clientes o de cierto tipo)
- `ReputationEffect` (oportunidad/riesgo de prestigio)
- `UnlockEffect` (abre contenido temporal)

Añadir un efecto nuevo = una clase `EventEffect` nueva, sin editar el `EventEngine`.

## 5. Motor de eventos (flujo)

```
Cada avance de jornada/semana → EventScheduler evalúa triggers →
  activa EventData válidos → EventEngine aplica sus EventEffect →
  UI notifica al jugador (y ofrece opciones si es interactivo) →
  al expirar → EventEngine retira los efectos → registra en historial
```

## 6. Interacción del jugador 🟡

Algunos eventos son **pasivos** (solo modifican el mundo); otros presentan una
**decisión** (aceptar un contrato de guerra, ayudar en la plaga) con consecuencias
en oro/reputación. Las decisiones usan el sistema de [Diálogo](10_Dialogue.md).

## 7. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `EventData` | Resource | Definición de un evento (trigger, duración, efectos) |
| `EventEffect` | Resource (base) | Contrato de un efecto aplicable/retirable |
| `EventScheduler` | system | Decide qué eventos se activan y cuándo |
| `EventEngine` | system | Aplica/retira efectos, mantiene eventos activos |
| `EventHistory` | data | Registro de eventos pasados (para logros/narrativa) |

## 8. Señales (EventBus)

- `event_started(event)`
- `event_choice_made(event, choice)`
- `event_ended(event)`

## 9. Preguntas abiertas

- 🔴 ¿Frecuencia objetivo de eventos (para no saturar ni aburrir)? Calibrar con ritmo.
- 🔴 ¿Los eventos narrativos son una capa aparte de [Quests](11_Quests.md) o el mismo sistema?
  Recomendado: eventos = mundo/economía; misiones = objetivos del jugador; se comunican por señales.
- 🟡 Set inicial de eventos para v1.0.
