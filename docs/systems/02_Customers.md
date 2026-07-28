# 02 — Sistema de Clientes

> Cómo llegan, qué quieren y cómo compran los clientes. Es el corazón del bucle
> minuto a minuto. Distingue **clientes genéricos** (relleno vivo) de **clientes
> recurrentes** (con nombre y arco). Los héroes son un tipo especial de cliente,
> ver [Heroes](03_Heroes.md). Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- Que atender se sienta **vivo y variado**, no un botón de "vender".
- Cada cliente trae una **petición legible** que el jugador resuelve.
- Los recurrentes crean **vínculo emocional** (recuerdan, evolucionan).
- Todo cliente es **datos + componentes**, generado, no hardcodeado.

## 2. Anatomía de un cliente (composición)

Un cliente en el mostrador = escena `Customer` compuesta por:

- `CharacterView` — retrato/sprite y animación.
- `CustomerNeed` (dato) — qué quiere (ver §4).
- `MoodComponent` — ánimo/paciencia (afecta a negociación).
- `WalletComponent` — cuánto puede/está dispuesto a pagar.
- `DialogueComponent` — sus líneas (ver [Dialogue](10_Dialogue.md)).
- `ReputationComponent` (solo recurrentes) — cómo su satisfacción afecta prestigio.

Sin herencia profunda: un "héroe cliente" añade además un `HeroProfile`.

## 3. Tipos de cliente 🟡

| Tipo | Descripción | Frecuencia |
|------|-------------|-----------|
| **Genérico** | Aldeano/aventurero sin nombre, petición simple | mayoría |
| **Recurrente** | NPC con nombre, arco y preferencias (ver [NPCs](../NPCs.md)) | limitado |
| **Héroe** | Cliente que además parte a la mazmorra | especial |
| **VIP / facción** | Cliente de élite desbloqueado por reputación | raro, lucrativo |

## 4. La petición (`CustomerNeed`)

Cada cliente llega con una necesidad, que puede ser:

- **Compra directa:** quiere un objeto de una categoría/calidad ("una espada
  decente por menos de X").
- **Encargo (commission):** pide fabricar algo específico para una fecha
  (ver [Crafting](05_Crafting.md) y [Quests](11_Quests.md)).
- **Consejo/servicio:** repara, identifica, o pregunta (gancho narrativo).

`CustomerNeed` es un `Resource` con: categoría, calidad deseada, presupuesto,
urgencia, y flexibilidad (cuánto tolera desviaciones).

## 5. Generación de clientes 🟡

- `CustomerSpawner` (system) produce clientes por jornada según:
  reputación (más prestigio → más y mejores clientes), eventos activos, día de la
  semana, y facciones desbloqueadas.
- Los recurrentes tienen **probabilidad/condición de aparición** ligada a su arco.
- La composición se arma desde plantillas en `resources/customers/`.

## 6. Flujo de atención (bucle central)

```
Spawner crea cliente → entra y se coloca en el mostrador →
  presenta CustomerNeed (diálogo) → jugador ofrece objeto y precio →
  MoodComponent evalúa oferta vs presupuesto/ánimo →
    acepta → EconomySystem.resolve_sale → reputación + posible lealtad
    contraoferta → negociación (ver §7)
    rechaza → se va (impacto leve en ánimo/reputación según trato)
```

## 7. Negociación (haggle) 🔴

Tres opciones sobre la mesa (decisión pendiente, ver [Economy](01_Economy.md)):

1. **Por ánimo (automática):** el cliente acepta/rechaza según `MoodComponent` y
   desviación del precio justo. Simple, *cozy*.
2. **Por diálogo:** el jugador elige réplicas que suben/bajan la disposición.
3. **Minijuego ligero.** (Riesgo: puede romper el tono cozy.)

**Recomendación de diseño:** opción 1 como base + toques de opción 2 en clientes
recurrentes. Cerrar antes de Fase 4.

## 8. Ánimo y paciencia

- `MoodComponent` va de "encantado" a "molesto"; afecta al margen que aceptan y a
  la reputación que otorgan.
- Buen trato (precio justo, saludo, producto adecuado) sube ánimo → **propinas**,
  reseñas, lealtad. Mal trato lo baja.
- Nunca hay penalización dura por un cliente perdido: es *feedback*, no castigo.

## 9. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `CustomerData` | Resource | Plantilla de cliente (recurrentes/genéricos) |
| `CustomerNeed` | Resource | Qué quiere esta visita |
| `CustomerSpawner` | system | Decide quién llega y cuándo |
| `CustomerController` | system | Máquina de estados de una visita (llegar/pedir/negociar/irse) |
| `HaggleResolver` | system (puro) | Resuelve si una oferta se acepta |
| `MoodComponent` | component | Ánimo/paciencia |
| `CustomerView` | ui | Presentación (no lógica de reglas) |

## 10. Señales (EventBus)

- `customer_arrived(customer)`
- `customer_need_presented(need)`
- `customer_satisfied(customer, level)` / `customer_left_unhappy(customer)`
- alimenta reputación, logros y arcos de recurrentes.

## 11. Preguntas abiertas

- 🔴 Mecánica de negociación (§7).
- 🔴 ¿Cola de clientes simultánea o de uno en uno en el mostrador? Afecta a UI y ritmo.
- 🟡 Cuántos recurrentes en v1.0 (objetivo ~20, ver GDD scope).
