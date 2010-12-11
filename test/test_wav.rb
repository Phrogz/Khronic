require_relative '../lib/khronic/wav.rb'

amp    = 2**15-1
period = 11.0

samples1 = (0..(2*44100)).map{ |i|
	(amp*Math.sin(i/period)).round
}
samples2 = (0..(2*44100)).map{ |i|
	(amp*Math.cos(i/period)).round
}


w = WAV.from_samples( [samples1,samples2], :rate=>4000 )
puts w.debug
w.write( 'sin.wav' )