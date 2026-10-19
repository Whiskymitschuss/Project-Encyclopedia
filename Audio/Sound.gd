extends Node

var player: AudioStreamPlayer

func _ready() -> void:
 player = AudioStreamPlayer.new()
 add_child(player)
 player.volume_db = -18

func play_tone(frequency: float, duration: float) -> void:
 if Game.state.muted or DisplayServer.get_name() == "headless": return
 var stream = AudioStreamWAV.new()
 stream.mix_rate = 22050
 stream.format = AudioStreamWAV.FORMAT_16_BITS
 var bytes = PackedByteArray()
 var samples = int(22050*duration)
 bytes.resize(samples*2)
 for i in samples:
  var envelope = pow(1.0-float(i)/samples,2.0)
  var value = sin(float(i)*frequency*TAU/22050.0)*envelope*0.7
  bytes.encode_s16(i*2,int(value*32767))
 stream.data = bytes
 player.stream = stream
 player.play()

func play_chime() -> void:
 if Game.state.muted or DisplayServer.get_name()=="headless": return
 var stream=AudioStreamWAV.new()
 stream.mix_rate=22050
 stream.format=AudioStreamWAV.FORMAT_16_BITS
 var length=int(0.15*22050)
 var frequencies=[523.25,659.25,783.99]
 var data=PackedByteArray()
 data.resize(length*frequencies.size()*2)
 for note in frequencies.size():
  for i in length:
   var envelope=pow(1.0-float(i)/length,2)
   var value=sin(float(i)*frequencies[note]*TAU/22050)*envelope*0.5
   data.encode_s16((note*length+i)*2,int(value*32767))
 stream.data=data
 player.stream=stream
 player.play()
