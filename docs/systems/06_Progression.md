# 06 — Sistema de Progresión

> Cómo crece el jugador y su tienda a lo largo de la partida. Une economía,
> reputación, fabricación y desbloqueos en una curva satisfactoria. Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- Sensación constante de **crecimiento** sin muros de farmeo.
- Cada desbloqueo **abre juego nuevo** (mecánica, contenido o clientela), no solo
  números más grandes.
- Progresión **legible**: el jugador siempre sabe cuál es su próxima meta.

## 2. Ejes de progresión

| Eje | Recurso que lo mueve | Qué desbloquea |
|-----|----------------------|----------------|
| **Rango de tienda** | Prestigio (reputación) | Más clientela, ampliaciones, metas |
| **Facciones** | Afinidad de facción | Clientela élite, materiales, recetas |
| **Fabricación** | Reputación/oro/aprendizaje | Estaciones, recetas, mejoras |
| **Local** | Oro | Espacio, decoración, estanterías, almacén |
| **Equipo humano** | Oro/reputación | Empleados (fabricar, atender) |
| **Mundo** | Reputación/misiones | Nuevos barrios/localizaciones |

## 3. Rango de tienda (columna vertebral) 🟡

```
Puesto polvoriento → Tienda de Bronce → de Plata → de Oro → Legendaria del Reino
```

Cada rango:
- Sube el **techo** de clientela, precios y ampliaciones posibles.
- Otorga una **meta de negocio** clara (el "próximo objetivo" del GDD §8).
- Marca hitos narrativos (el pueblo/el reino reconoce tu ascenso).

Subir de rango requiere una **combinación** de prestigio + hitos (no solo oro),
para que el crecimiento sea integral.

## 4. Mejora del local

- **Estanterías/expositores:** más *slots* de venta, mejor presentación (afecta a
  demanda/ánimo).
- **Almacén:** capacidad de inventario (ver [Inventory](09_Inventory.md)).
- **Estaciones:** ver [Crafting](05_Crafting.md).
- **Decoración:** cosmético + pequeño bonus de ambiente/ánimo (gancho *cozy*).
- **Ampliaciones de sala:** desbloquean espacio para lo anterior.

## 5. Empleados 🟡

Desbloqueables a mediano plazo para delegar:
- **Dependiente:** atiende clientes genéricos mientras fabricas.
- **Aprendiz:** fabrica objetos de baja complejidad.
- Tienen **salario** (ver [Economy](01_Economy.md)) y **skill** que mejora con uso.
- Composición: un empleado = `CharacterView` + `WalletComponent` (salario) +
  `SkillSet` + un rol asignado.

## 6. Habilidades/profesiones del jugador 🟡

`resources/skills/` y `resources/professions/` definen mejoras pasivas/activas que
el jugador desbloquea (mejor regateo, menos defectos, más aforo). Se ganan por uso
o por hitos. 🔴 Definir si hay árbol de habilidades o mejoras lineales (Fase 6).

## 7. Curva y ritmo 🟡

- **Inicio (t. bronce):** enseñar el bucle básico, pocas categorías, 1–2 estaciones.
- **Medio (plata/oro):** abrir facciones, encargos, héroes con arco, empleados.
- **Tardío (legendaria):** economía a gran escala, eventos mayores, cierre de arcos.
- Curvas numéricas parametrizadas en `resources/config/` para poder calibrar.

## 8. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `ProgressionConfig` | Resource | Umbrales de rango, costes de mejora, curvas |
| `ShopRank` | data | Estado del rango actual y requisitos del siguiente |
| `UnlockSystem` | system | Otorga desbloqueos cuando se cumplen condiciones |
| `UpgradeData` | Resource | Una mejora concreta (coste, efecto, requisitos) |
| `ProgressionSystem` | system | Rastrea ejes y dispara subidas de rango |

`UnlockSystem` escucha señales (reputación, oro, misiones) y aplica desbloqueos de
forma centralizada → un único sitio donde vive la lógica de "qué abre qué".

## 9. Señales (EventBus)

- `shop_rank_up(rank)`
- `upgrade_purchased(upgrade)`
- `employee_hired(employee)`
- `location_unlocked(location)`

## 10. Preguntas abiertas

- 🔴 Árbol de habilidades vs. mejoras lineales del jugador.
- 🔴 ¿Cuántos rangos de tienda exactos y qué requisitos por rango? (Fase con Economy).
- 🟡 Número y roles de empleados en v1.0.
