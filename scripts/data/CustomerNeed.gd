class_name CustomerNeed
extends RefCounted
## Lo que quiere un cliente en UNA visita concreta. Se genera al vuelo desde un
## CustomerData (no se autora a mano). Ver docs/systems/02_Customers.md §4.

## Vía por la que el cliente resuelve su compra (modelo híbrido, Fase 4):
## COUNTER = venta atendida en el mostrador (con regateo por ánimo);
## SHELF   = compra directa de un producto expuesto en la estantería.
enum Intent { COUNTER, SHELF }

## Categoría deseada.
var category: GameEnums.Category = GameEnums.Category.POTION
## Calidad mínima aceptable (0..5).
var min_quality: int = 0
## Máximo que está dispuesto a pagar (coronas).
var budget: int = 0
## Flexibilidad 0..1: cuánto tolera desviaciones (calidad/precio). Reservado para
## afinar el comportamiento en playtesting.
var flexibility: float = 0.5
## Vía elegida para esta visita.
var intent: Intent = Intent.COUNTER
