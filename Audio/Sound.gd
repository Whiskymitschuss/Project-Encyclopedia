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
