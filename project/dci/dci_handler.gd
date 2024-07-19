extends dci_context
class_name dci_handler

var _exec: Callable

func with_callable(c: Callable) -> dci_handler:
	_exec = c
	return self
	
# override
func _on_execute(data):
	_exec.call(self, data)
	
