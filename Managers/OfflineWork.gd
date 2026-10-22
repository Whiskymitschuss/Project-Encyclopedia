extends RefCounted
# Owns a detached simulation. The worker never touches the scene, current company
# or save files. Only progress crosses the mutex; the final state is taken after
# joining the thread. Android can still suspend or terminate the whole process.
var thread=Thread.new()
var mutex=Mutex.new()
var simulation: Node
var remaining=0.0
var complete=false
var canceled=false

func start(model: Node, seconds: float) -> Error:
 simulation=model
 remaining=seconds
 var error=thread.start(run)
 if error!=OK:
  simulation.free()
  simulation=null
 return error

func run() -> void:
 var left=remaining
 while left>0:
  mutex.lock()
  var stop=canceled
  mutex.unlock()
  if stop: return
  # Publish in short batches, independent of rendering or application pause.
  for i in 32:
   if left<=0: break
   var amount=minf(1,left)
   simulation.step(amount)
   left=maxf(0,left-amount)
  mutex.lock()
  remaining=left
  mutex.unlock()
 mutex.lock()
 complete=true
 mutex.unlock()

func progress() -> Dictionary:
 mutex.lock()
 var result={"remaining":remaining,"complete":complete}
 mutex.unlock()
 return result

func take() -> Dictionary:
 thread.wait_to_finish()
 var result={"state":simulation.state,"flow":simulation.flow}
 simulation.free()
 simulation=null
 return result

func stop() -> void:
 mutex.lock()
 canceled=true
 mutex.unlock()
 if thread.is_started(): thread.wait_to_finish()
 if is_instance_valid(simulation): simulation.free()
 simulation=null
