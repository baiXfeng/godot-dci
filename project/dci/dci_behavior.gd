extends RefCounted
class_name dci_behavior

var _data

func _init(d):
	_data = d
	_data._set_behavior(self)
	
func data():
	return _data
	
func cast(role: String) -> dci_behavior:
	return _data.cast(role)
	
func execute(name: String, data = null) -> dci_behavior:
	_data.env().execute(name, self, data)
	return self
	
func add_component(name: String, component) -> dci_behavior:
	_data.env().add_component(_data, name, component)
	return self
	
func remove_component(name: String) -> dci_behavior:
	_data.env().remove_component(_data, name)
	return self
	
func remove_all_components():
	_data.env().remove_all_components(_data)
	return self
	
func has_component(name: String) -> bool:
	return _data.env().has_component(_data, name)
	
func get_component(name: String):
	return _data.env().get_component(_data, name)
	
func get_components() -> Array:
	return _data.env().get_components(_data)
	
func on_enter(data):
	_on_enter(data)
	
func on_exit(data):
	_on_exit(data)
	
# ==============================================================================
	
# override
func _on_enter(data):
	pass
	
# override
func _on_exit(data):
	pass
	
