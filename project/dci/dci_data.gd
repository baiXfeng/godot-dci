extends RefCounted
class_name dci_data

signal on_init(sender)
signal on_destroy(sender)

signal on_component_added(sender, component)
signal on_component_removed(sender, component)

func id() -> int:
	return _id
	
func with(env) -> dci_data:
	env.add_data(self)
	return self
	
func destroy():
	env().remove_data(self)
	
func env() -> dci_env:
	return _env.get_ref()
	
func behavior():
	return _behavior
	
func cast(role: String) -> dci_behavior:
	return env().cast_behavior(self, role)
	
func execute(name: String, data = null) -> dci_data:
	env().execute(name, self, data)
	return self
	
func add_to_group(group_name: String) -> bool:
	return env().add_data_to_group(self, group_name)
	
func remove_from_group(group_name: String) -> bool:
	return env().remove_data_from_group(self, group_name)
	
func get_groups() -> Array:
	return env().get_data_groups(self)
	
# ==============================================================================
# private
var _id: int	# 唯一实例id
var _env: WeakRef
var _behavior
	
func _set_id(id: int):
	_id = id
	
func _set_env(f: dci_env):
	_env = weakref(f)
	
func _set_behavior(behavior):
	if _behavior:
		_behavior.on_exit(self)
	_behavior = behavior
	if _behavior:
		_behavior.on_enter(self)
	
