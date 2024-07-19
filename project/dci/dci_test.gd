extends RefCounted
class_name dci_test

var dci: dci_env = dci_env.new()

# talker role
class Talker extends dci_behavior:
	func speak(message: String) -> dci_behavior:
		print("role <%d> speak: %s" % [data().id(), message])
		return self
	
# simmer role
class Swimmer extends dci_behavior:
	func swim() -> dci_behavior:
		print("role <%d> swim now." % data().id())
		return self
	
# superman role
class Superman extends dci_behavior:
	func fly() -> dci_behavior:
		print("role <%d> fly now." % data().id())
		return self
	
# talk context
class TalkContext extends dci_context:
	# override
	func _on_execute(data):
		var role_1: Talker = data.role_1
		var role_2: Talker = data.role_2
		role_1.speak("How are you?")
		role_2.speak("I'm fine.")
	
# entity context
class EntityContext extends dci_context:
	# override
	func _on_execute(data):
		var role_1: dci_behavior = data.role_1
		var role_2: dci_behavior = data.role_2
	
func _init():
	dci.debug_print = true
	
	# register behavior
	dci.add_behavior("Talker", Talker)
	dci.add_behavior("Swimmer", Swimmer)
	dci.add_behavior("Superman", Superman)
	
	# register context
	dci.add_context("TalkContext", TalkContext.new())
	dci.add_context("EntityContext", EntityContext.new())
	dci.add_callable("LambdaContext", func(ctx: dci_context, data):
		print("This is a lambda context.")
	)
	
	# some test
	_test_data_and_behavior()
	_test_context()
	_check()
	
func _test_data_and_behavior():
	var data = dci_data.new().with(dci)
	data.cast("Talker").speak("I'm talker NO.%d." % data.id())
	data.add_to_group("person")
	
	data = dci_data.new().with(dci)
	data.cast("Talker").speak("I'm talker NO.%d." % data.id())
	data.add_to_group("person")
	
	var groups = dci.group("person")
	for d in groups:
		d.cast("Talker").speak("I'm in group <person> now by NO.%d." % d.id())
	
	var role: dci_data = dci.get_data(1)
	role.cast("Talker").speak("I can swim and fly.") \
		.cast("Swimmer").swim() \
		.cast("Superman").fly()
	
	# entity is internal role
	role.cast("entity") \
		.add_component("gold", 9999) \
		.add_component("hp", 100) \
		.add_component("power", 50)
	
func _test_context():
	dci.get_data(1).execute("TalkContext", {
		"role_1": dci.get_data(1).cast("Talker"),
		"role_2": dci.get_data(2).cast("Talker"),
	})
	dci.get_data(2).execute("TalkContext", {
		"role_1": dci.get_data(1).cast("Talker"),
		"role_2": dci.get_data(2).cast("Talker"),
	})
	var role: dci_data = dci.group("person").front()
	role.execute("LambdaContext")
	
	role.execute("TalkContext", {
		"role_1": dci.get_data(1).cast("Talker"),
		"role_2": dci.get_data(2).cast("Talker"),
	})
	role.execute("EntityContext", {
		"role_1": dci.get_data(1).cast("Talker"),
		"role_2": dci.get_data(2).cast("Talker"),
	})
	
func _check():
	printt("person number before:", dci.group("person").size())
	for data in dci.group("person"):
		var names = data.get_groups()
		for name in names:
			data.remove_from_group(name)
	printt("person number after:", dci.group("person").size())
	
	var role: dci_data = dci.get_data(1)
	printt("component number before:", role.cast("entity").get_components().size())
	role.cast("entity").remove_all_components()
	printt("component number after:", role.cast("entity").get_components().size())
	
	printt("data list before:", dci.data_keys())
	for id in dci.data_keys():
		dci.remove_data_with_id(id)
	printt("data list after:", dci.data_keys())
	
