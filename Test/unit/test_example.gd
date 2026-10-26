extends GutTest
## Testes unitários do sistema de inventário (Resources/inventory.gd).
## Cobre: adicionar item, remover item, capacidade máxima e transferência entre slots.

const CAPACIDADE := 12  # mesmo número de slots do playerInventory.tres

var inventory: Inventory
var potato: InventoryItem
var strawberry: InventoryItem


func before_each() -> void:
	inventory = Inventory.new()
	for i in CAPACIDADE:
		inventory.slots.append(InventorySlot.new())
	potato = _criar_item("potato")
	strawberry = _criar_item("strawberry")


# ---------- helpers ----------

func _criar_item(nome: String) -> InventoryItem:
	var item := InventoryItem.new()
	item.name = nome
	return item


func _slots_ocupados() -> int:
	var total := 0
	for slot in inventory.slots:
		if slot.item:
			total += 1
	return total


func _transferir(indice_origem: int, indice_destino: int) -> void:
	# mesmo fluxo da UI: takeItem() chama removeSlot() e depois insert() chama insertSlot()
	var slot := inventory.slots[indice_origem]
	inventory.removeSlot(slot)
	inventory.insertSlot(indice_destino, slot)


func _encher_inventario() -> Array[InventoryItem]:
	# um item diferente por slot, para não empilhar
	var itens: Array[InventoryItem] = []
	for i in CAPACIDADE:
		var item := _criar_item("item_%d" % i)
		itens.append(item)
		inventory.insert(item)
	return itens


# ---------- adicionar item ----------

func test_insert_em_inventario_vazio_ocupa_o_primeiro_slot() -> void:
	inventory.insert(potato)

	assert_eq(inventory.slots[0].item, potato, "item deve ir para o slot 0")
	assert_eq(inventory.slots[0].amount, 1, "quantidade inicial deve ser 1")
	assert_eq(_slots_ocupados(), 1)


func test_insert_do_mesmo_item_empilha_no_slot_existente() -> void:
	inventory.insert(potato)
	inventory.insert(potato)
	inventory.insert(potato)

	assert_eq(inventory.slots[0].amount, 3, "três inserções devem empilhar em 3")
	assert_eq(_slots_ocupados(), 1, "não deve ocupar um segundo slot")


func test_insert_de_itens_diferentes_usa_slots_diferentes() -> void:
	inventory.insert(potato)
	inventory.insert(strawberry)

	assert_eq(inventory.slots[0].item, potato)
	assert_eq(inventory.slots[1].item, strawberry)
	assert_eq(inventory.slots[1].amount, 1)


func test_insert_preenche_o_primeiro_slot_vazio_depois_de_uma_remocao() -> void:
	inventory.insert(potato)      # slot 0
	inventory.insert(strawberry)  # slot 1
	inventory.removeItemAtIndex(0)

	var onion := _criar_item("onion")
	inventory.insert(onion)

	assert_eq(inventory.slots[0].item, onion, "slot 0 liberado deve ser reaproveitado")
	assert_eq(inventory.slots[1].item, strawberry)


func test_insert_emite_sinal_updated_ao_criar_novo_slot() -> void:
	watch_signals(inventory)

	inventory.insert(potato)

	assert_signal_emitted(inventory, "updated")
	assert_signal_emit_count(inventory, "updated", 1)


func test_insert_emite_sinal_updated_ao_empilhar() -> void:
	inventory.insert(potato)
	watch_signals(inventory)

	inventory.insert(potato)

	assert_signal_emit_count(inventory, "updated", 1)


# ---------- remover item ----------

func test_remove_item_esvazia_o_slot() -> void:
	inventory.insert(potato)

	inventory.removeItemAtIndex(0)

	assert_null(inventory.slots[0].item, "slot não deve ter item")
	assert_eq(inventory.slots[0].amount, 0, "quantidade deve voltar a 0")


func test_remove_remove_a_pilha_inteira() -> void:
	inventory.insert(potato)
	inventory.insert(potato)
	inventory.insert(potato)

	inventory.removeItemAtIndex(0)

	assert_eq(_slots_ocupados(), 0, "a pilha toda some, não só uma unidade")


func test_remove_nao_altera_os_outros_slots() -> void:
	inventory.insert(potato)
	inventory.insert(strawberry)

	inventory.removeItemAtIndex(0)

	assert_eq(inventory.slots[1].item, strawberry)
	assert_eq(inventory.slots[1].amount, 1)


func test_remove_mantem_o_tamanho_do_inventario() -> void:
	inventory.insert(potato)

	inventory.removeItemAtIndex(0)

	assert_eq(inventory.slots.size(), CAPACIDADE)


func test_remove_em_slot_ja_vazio_nao_quebra() -> void:
	inventory.removeItemAtIndex(5)

	assert_null(inventory.slots[5].item)
	assert_eq(inventory.slots.size(), CAPACIDADE)


func test_item_pode_ser_inserido_de_novo_depois_de_removido() -> void:
	inventory.insert(potato)
	inventory.removeItemAtIndex(0)

	inventory.insert(potato)

	assert_eq(inventory.slots[0].item, potato)
	assert_eq(inventory.slots[0].amount, 1, "começa uma pilha nova, sem lixo da anterior")


func test_remove_slot_esvazia_o_slot_informado() -> void:
	inventory.insert(potato)

	inventory.removeSlot(inventory.slots[0])

	assert_null(inventory.slots[0].item)
	assert_eq(inventory.slots[0].amount, 0)


func test_remove_slot_de_slot_que_nao_pertence_ao_inventario_nao_faz_nada() -> void:
	inventory.insert(potato)
	var slot_de_fora := InventorySlot.new()

	inventory.removeSlot(slot_de_fora)

	assert_eq(inventory.slots[0].item, potato)
	assert_eq(inventory.slots.size(), CAPACIDADE)


# ---------- capacidade máxima ----------

func test_inventario_aceita_itens_diferentes_ate_a_capacidade() -> void:
	_encher_inventario()

	assert_eq(_slots_ocupados(), CAPACIDADE, "todos os 12 slots devem estar ocupados")


func test_insert_em_inventario_cheio_nao_adiciona_item_novo() -> void:
	_encher_inventario()
	var extra := _criar_item("extra")

	inventory.insert(extra)

	for slot in inventory.slots:
		assert_ne(slot.item, extra, "item extra não pode aparecer em nenhum slot")
	assert_eq(inventory.slots.size(), CAPACIDADE, "o inventário não cresce")


func test_insert_em_inventario_cheio_nao_emite_updated() -> void:
	_encher_inventario()
	watch_signals(inventory)

	inventory.insert(_criar_item("extra"))

	assert_signal_not_emitted(inventory, "updated")


func test_inventario_cheio_ainda_empilha_item_que_ja_existe() -> void:
	var itens := _encher_inventario()

	inventory.insert(itens[3])

	assert_eq(inventory.slots[3].amount, 2, "empilhar não precisa de slot livre")


func test_liberar_um_slot_de_inventario_cheio_permite_novo_item() -> void:
	_encher_inventario()
	inventory.removeItemAtIndex(7)
	var extra := _criar_item("extra")

	inventory.insert(extra)

	assert_eq(inventory.slots[7].item, extra)


# ---------- transferir itens ----------

func test_transferir_move_o_item_para_o_slot_de_destino() -> void:
	inventory.insert(potato)

	_transferir(0, 5)

	assert_eq(inventory.slots[5].item, potato)


func test_transferir_preserva_a_quantidade() -> void:
	inventory.insert(potato)
	inventory.insert(potato)
	inventory.insert(potato)

	_transferir(0, 5)

	assert_eq(inventory.slots[5].amount, 3)


func test_transferir_esvazia_o_slot_de_origem() -> void:
	inventory.insert(potato)

	_transferir(0, 5)

	assert_null(inventory.slots[0].item, "origem fica vazia")
	assert_eq(inventory.slots[0].amount, 0)


func test_transferir_nao_duplica_o_item() -> void:
	inventory.insert(potato)

	_transferir(0, 5)

	assert_eq(_slots_ocupados(), 1, "só um slot deve ter o item depois de mover")


func test_transferir_nao_altera_slots_nao_envolvidos() -> void:
	inventory.insert(potato)      # slot 0
	inventory.insert(strawberry)  # slot 1

	_transferir(0, 5)

	assert_eq(inventory.slots[1].item, strawberry)
	assert_eq(inventory.slots[1].amount, 1)


func test_transferir_mantem_o_tamanho_do_inventario() -> void:
	inventory.insert(potato)

	_transferir(0, 5)

	assert_eq(inventory.slots.size(), CAPACIDADE)


func test_transferir_para_o_slot_vizinho_e_de_volta() -> void:
	inventory.insert(potato)
	inventory.insert(potato)

	_transferir(0, 1)
	_transferir(1, 0)

	assert_eq(inventory.slots[0].item, potato)
	assert_eq(inventory.slots[0].amount, 2)
	assert_null(inventory.slots[1].item)


# ---------- casos de borda (comportamento desejado) ----------

func test_transferir_para_slot_ocupado_nao_pode_perder_o_item_do_destino() -> void:
	inventory.insert(potato)      # slot 0
	inventory.insert(strawberry)  # slot 1

	inventory.insertSlot(1, inventory.slots[0])

	# insertSlot não pode sobrescrever um slot ocupado: a transferência é recusada
	assert_eq(inventory.slots[1].item, strawberry, "o item do destino foi perdido")
	assert_eq(inventory.slots[0].item, potato, "a origem não deve mudar se foi recusada")


func test_transferir_slot_que_nao_pertence_ao_inventario_nao_apaga_nada() -> void:
	inventory.insert(potato)
	_encher_inventario_restante()
	var ultimo_item := inventory.slots[CAPACIDADE - 1].item
	var slot_de_fora := InventorySlot.new()
	slot_de_fora.item = _criar_item("de_fora")
	slot_de_fora.amount = 1

	inventory.insertSlot(2, slot_de_fora)

	# find() devolve -1 e removeItemAtIndex(-1) esvazia o ÚLTIMO slot
	assert_eq(inventory.slots[CAPACIDADE - 1].item, ultimo_item,
		"o último slot não deveria ser apagado")


func _encher_inventario_restante() -> void:
	for i in range(1, CAPACIDADE):
		inventory.insert(_criar_item("filler_%d" % i))
