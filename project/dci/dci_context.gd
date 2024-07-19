extends Node
class_name dci_context
	
func env() -> dci_env:
	return _env.get_ref()
	
func sender():
	if _sender == null:
		return null
	return _sender.get_ref()
	
func execute(data = null):
	_on_execute(data)
	
func group(name: String) -> Array:
	return env().group(name)
	
func get_data(id: int) -> dci_data:
	return env().get_data(id)
	
# ==============================================================================
# override
func _on_execute(data):
	pass
	
# ==============================================================================
# private
var _env: WeakRef
var _sender: WeakRef
	
func _set_env(f: dci_env):
	_env = weakref(f)
	
func _set_sender(sender):
	_sender = weakref(sender)
	
func _init(parent: Node = null):
	# add scene tree for rpc
	if parent:
		parent.add_child(self)
	
