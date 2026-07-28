extends Node
## Bus global de señales entre sistemas desacoplados: el único punto de cruce
## entre features. Los sistemas EMITEN y ESCUCHAN aquí en vez de conocerse entre
## sí. Las señales se añaden a medida que cada fase las necesita.
## Autoload (ver project.godot). Ver docs/systems/00_Architecture.md §5-6.
##
## NO declara class_name para no chocar con el nombre del singleton.

# --- Economía (Fase 3) ---
signal item_sold(item: ItemData, price: int, buyer: Object)
signal material_purchased(material: ItemData, qty: int, cost: int)
signal wallet_changed(owner: Object, new_balance: int)
signal market_week_advanced(week: int)

# --- Clientes (Fase 4) ---
signal customer_arrived(customer: Object)
signal customer_need_presented(need: Object)
signal customer_satisfied(customer: Object, mood: float)
signal customer_left_unhappy(customer: Object)

# --- Tiempo (compartido) ---
signal day_advanced(day: int)

# Las señales de héroes, reputación, fabricación, eventos, misiones y logros se
# añadirán en sus respectivas fases (ver docs/systems/*).
