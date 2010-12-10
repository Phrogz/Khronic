require_relative '../lib/khronic/wav.rb'

amp    = 2**15-1
period = 11.0
p2 = 10.0

samples1 = (0..(2*44100)).map{ |i|
	(amp*Math.sin(i/period)).round
}
samples2 = (0..(2*44100)).map{ |i|
	(amp*Math.sin(i/(p2-=0.0001))).round
}


w = WAV.from_samples( [samples1,samples2], :rate=>22000 )
p w
w.write( 'sin.wav' )