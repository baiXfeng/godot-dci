extends Control

var dci: dci_env = dci_env.new("my-dci")

class swimmer extends dci_behavior:
	func swim() -> dci_behavior:
		print("%s Swim." % data().name)
		return self
	
class superman extends dci_behavior:
	func fly() -> dci_behavior:
		print("%s Fly." % data().name)
		return self
	
class tankman extends dci_behavior:
	func fire() -> dci_behavior:
		print("%s Fire!" % data().name)
		return self
	func attack() -> dci_behavior:
		print("%s Attack enemies!" % data().name)
		return self
	
class shopper extends  dci_behavior:
	func buy(name: String) -> dci_behavior:
		print("shopper <%s> age <%d> have gold <%d> to buy <%s>." % [data().name, data().age, get_component("gold"), name])
		return self
	
class Person extends dci_data:
	var age: int = 13
	var name: String = "Player"
	
class FlyContext extends dci_context:
	# override
	func _on_execute(data):
		assert(sender() is superman, "type not match!")
		sender().fly()
	
class BuySomeContext extends dci_context:
	# override
	func _on_execute(data):
		assert(sender() is shopper, "type not match!")
		sender().buy(data)
	
func _ready():
	#dci.debug_print = true
	
	# register role
	dci.add_behavior("swimmer", swimmer)
	dci.add_behavior("superman", superman)
	dci.add_behavior("tank", tankman)
	dci.add_behavior("shopper", shopper)
	
	# register context
	dci.add_context("BuySomeContext", BuySomeContext.new())
	dci.add_callable("attack_enemies", func(ctx: dci_context, data):
		ctx.sender().cast("tank").attack()
		printt("enemies:", data)
	)
	dci.add_callable("FlyLambda", func(ctx: dci_context, data):
		assert(ctx.sender() is superman, "type not match!")
		print("Here is lambda function.")
		ctx.sender().fly()
	)
	
	# data group
	var man: Person = Person.new().with(dci)
	man.add_to_group("player")
	
	for i in 5:
		var enemy: Person = Person.new().with(dci)
		enemy.add_to_group("enemy")
	
	# cast role
	man.cast("swimmer").swim() \
		.cast("superman").fly() \
		.cast("tank").fire()
	
	# cast to entity
	man.cast("entity") \
		.add_component("hello", 100) \
		.add_component("world", 200) \
		.add_component("gold", 9999)
	
	# cast to shopper
	var shopper = man.cast("shopper") \
		.execute("BuySomeContext", "drinks")
	
	man.cast("superman").execute("FlyLambda")
	
	# fetch enemies and execute context/callable
	var enemies = dci.group("enemy")
	man.cast("tank").execute("attack_enemies", enemies)
	
	# destory
	man.destroy()
	for d in dci.group("enemy"):
		d.destroy()
	
	printt("data list:", dci.data_keys())
	
