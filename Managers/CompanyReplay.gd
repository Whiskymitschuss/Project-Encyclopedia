extends RefCounted
var thread=Thread.new()
var mutex=Mutex.new()
var simulator: Node
var total=0.0
var completed=0.0
var canceled=false
func start(script: Script,snapshot: Dictionary,seconds: float) -> Error:
 total=seconds
 simulator=script.new()
 simulator.simulation_only=true
 simulator.set_block_signals(true)
 simulator.restore(snapshot)
 return thread.start(run)
func run() -> void:
 var left=total
 while left>0.00001:
  mutex.lock()
  var stop=canceled
  mutex.unlock()
  if stop: break
  var count=minf(32,left)
  simulator.simulate(count)
  left-=count
  mutex.lock()
  completed=total-left
  mutex.unlock()
func progress() -> float:
 mutex.lock()
 var value=completed/maxf(total,0.001)
 mutex.unlock()
 return value
func finished() -> bool: return thread.is_started() and not thread.is_alive()
func take() -> Dictionary:
 thread.wait_to_finish()
 var result=simulator.state.duplicate(true)
 simulator.free()
 simulator=null
 return result
func cancel() -> void:
 mutex.lock()
 canceled=true
 mutex.unlock()
 if thread.is_started(): thread.wait_to_finish()
 if is_instance_valid(simulator): simulator.free()
 simulator=null
