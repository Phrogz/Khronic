require_relative '../lib/khronic/wav.rb'

RATE = 44100
MAX  = 2**15-1

C3 = 130.81
E3 = 164.81
G3 = 196.00
C4 = 261.63
E4 = 329.63
G4 = 392.00

def period(pitch)
	RATE/pitch/(Math::PI*2)
end

module Enumerable
	def sum
		inject(0){ |sum,o| o ? sum+o : sum }
	end
end

require 'pp'

def chord( wav, notes )
	notes = notes.split(/\s+/)
	notes_chs = notes.map{ |n| wav.pitch( n, samples_only:true ) }
	chord = notes_chs.transpose.map do |channel_notes|
		channel_notes.shift.zip(*channel_notes).map{ |ss| ss.sum.to_f / ss.length }.map(&:round)
	end
	Khronic::WAV.from_samples( chord )
end

if __FILE__==$0
	pad = Khronic::WAV.from_file( 'docs/wavs/lead.wav' )
	p pad
	chord(pad, 'c4 g4' ).write( 'cgpad.wav' )
end
__END__
notes = [C3,C4,E4,G3].map{ |pitch|
	(0...4*RATE).map{ |i|
		MAX * Math.sin( i/period(pitch) )
	}.map(&:round)
}
chord = notes.shift.zip(*notes).map{ |notes| notes.sum.to_f / notes.length }.map(&:round)

k = Khronic::WAV.from_file( '../wavs/kick.wav' )

kick = k.samples
(0...RATE/4).each{ |i| kick[i] ||= 0 }
kick *= 16

samples = chord.zip(kick).map{ |samples| samples.sum.to_f / samples.length }.map(&:round)



w = Khronic::WAV.from_samples( samples, rate:RATE )
p k,w
w.write( 'chordkick_44k.wav' )

