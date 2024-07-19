extends RefCounted
class_name dci_env

var debug_print: bool

# data
var _name: String
var _idCount: int
var _data_map: Dictionary
var _id_data_map: Dictionary
var _context_map: Dictionary
var _behavior_map: Dictionary
var _component_map: Dictionary
# group
var _group_data_map: Dictionary
var _data_group_keys: Dictionary

func _init(name = "dci_env"):
	_name = name
	add_behavior("entity", preload("dci_behavior.gd"))
	
func add_data(data) -> bool:
	if not _data_map.has(data):
		_idCount += 1
		_id_data_map[_idCount] = data
		data._set_id(_idCount)
		if debug_print:
			printt("data <%d> add to dci_env." % data.id())
	_data_map[data] = true
	data._set_env(self)
	data.on_init.emit(data)
	return true
	
func remove_data(data) -> bool:
	data.on_destroy.emit(data)
	data._set_behavior(null)
	remove_all_components(data)
	_remove_data_groups(data)
	_id_data_map.erase(data.id())
	if debug_print:
		printt("data <%d> remove from dci_env." % data.id())
	return _data_map.erase(data)
	
func remove_data_with_id(id: int) -> bool:
	var data = get_data(id)
	if data == null:
		return false
	return remove_data(data)
	
func get_data(id: int):
	if _id_data_map.has(id):
		return _id_data_map[id]
	return null
	
func data_keys() -> Array:
	return _id_data_map.keys()
	
func add_component(data, name: String, component) -> bool:
	var pool = _get_component_map(data)
	pool[name] = component
	data.on_component_added.emit(data, component)
	if debug_print:
		printt("data <%d> add component <%s>." % [data.id(), name])
	return true
	
func remove_component(data, name: String) -> bool:
	var pool = _get_component_map(data)
	if pool.has(name):
		var c = pool[name]
		pool.erase(name)
		data.on_component_removed.emit(data, c)
		if debug_print:
			printt("data <%d> remove component <%s>." % [data.id(), name])
		return true
	return false
	
func remove_all_components(data):
	var pool = _get_component_map(data)
	var keys = pool.keys()
	for name in keys:
		remove_component(data, name)
	_component_map.erase(data)
	
func has_component(data, name: String) -> bool:
	var pool = _get_component_map(data)
	return pool.has(name)
	
func get_component(data, name: String):
	var pool = _get_component_map(data)
	if pool.has(name):
		return pool[name]
	return null
	
func get_components(data) -> Array:
	var pool = _get_component_map(data)
	var ret = []
	for name in pool.keys():
		ret.append(pool[name])
	return ret
	
func add_data_to_group(data, name: String) -> bool:
	var pool = _get_group_data_map(name)
	pool[data] = true
	var keys = _get_data_group_keys(data)
	keys[name] = true
	if debug_print:
		printt("data <%d> add to group <%s>." % [data.id(), name])
	return true
	
func remove_data_from_group(data, name: String) -> bool:
	var pool = _get_group_data_map(name)
	var keys = _get_data_group_keys(data)
	keys.erase(name)
	if debug_print:
		printt("data <%d> remove from group <%s>." % [data.id(), name])
	return pool.erase(data)
	
func get_data_groups(data) -> Array:
	return _get_data_group_keys(data).keys()
	
func group(name: String) -> Array:
	var pool = _get_group_data_map(name)
	return pool.keys()
	
func execute(name: String, sender, data = null):
	if not has_context(name):
		return
	if debug_print:
		printt("context <%s> execute with data %s." % [name, data])
	var c = get_context(name)
	var prev = c.sender()
	c._set_sender(sender)
	c.execute(data)
	c._set_sender(prev)
	
func add_behavior(role: String, behavior: Resource) -> bool:
	_behavior_map[role] = behavior
	if debug_print:
		printt("behavior <%s> add to dci_env." % role)
	return true
	
func remove_behavior(role: String) -> bool:
	if debug_print:
		printt("behavior <%s> remove dci_env." % role)
	return _behavior_map.erase(role)
	
func has_behavior(role: String) -> bool:
	return _behavior_map.has(role)
	
func get_behavior(role: String) -> Resource:
	return _behavior_map[role]
	
func cast_behavior(data, role: String):
	if not has_behavior(role):
		return null
	if debug_print:
		printt("data <%d> cast to role <%s>." % [data.id(), role])
	return get_behavior(role).new(data)
	
func add_context(name: String, context) -> bool:
	_context_map[name] = context
	if debug_print:
		printt("context <%s> add to dci_env." % name)
	return true
	
func remove_context(name: String) -> bool:
	if debug_print:
		printt("context <%s> remove from dci_env." % name)
	return _context_map.erase(name)
	
func remove_all_contexts():
	_context_map.clear()
	
func has_context(name: String) -> bool:
	return _context_map.has(name)
	
func get_context(name: String):
	return _context_map[name]
	
func add_callable(name: String, c: Callable, parent: Node = null) -> bool:
	return add_context(name, preload("dci_handler.gd").new(parent).with_callable(c))
	
# ==============================================================================
# private
	
func _remove_data_groups(data):
	var keys = _get_data_group_keys(data)
	for group_name in keys:
		var pool = _get_group_data_map(group_name)
		pool.erase(data)
	
func _get_component_map(data) -> Dictionary:
	if not _component_map.has(data):
		_component_map[data] = {}
	return _component_map[data]
	
func _get_group_data_map(name) -> Dictionary:
	if not _group_data_map.has(name):
		_group_data_map[name] = {}
	return _group_data_map[name]
	
func _get_data_group_keys(data) -> Dictionary:
	if not _data_group_keys.has(data):
		_data_group_keys[data] = {}
	return _data_group_keys[data]
	
