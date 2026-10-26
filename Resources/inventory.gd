extends Resource
 
class_name Inventory
 
signal updated
 
@export var slots: Array[InventorySlot]
 
func insert(item: InventoryItem):
	for slot in slots:
		if slot.item == item:
			slot.amount += 1
			updated.emit()
			return
	
	for i in range(slots.size()):
		if !slots[i].item:
			slots[i].item = item
			slots[i].amount = 1
			updated.emit()
			return
			
 
func removeSlot(inventorySlot: InventorySlot):
	var index = slots.find(inventorySlot)
	if index < 0: return
	slots[index] = InventorySlot.new()
	
func removeItemAtIndex(index: int):
	slots[index] = InventorySlot.new()
	
func insertSlot(index: int, inventorySlot: InventorySlot) -> bool:
	if index < 0 or index >= slots.size(): return false
	if slots[index].item: return false # destino ocupado: não sobrescreve
	slots[index] = inventorySlot
	return true
