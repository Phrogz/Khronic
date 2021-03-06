require_relative 'helper'
require 'tmpdir'

class TestWAV < MT
	W = Khronic::WAV
	def test_create_mono
		rise = *(-50..50)
		mono1 = W.from_samples rise
		mono2 = W.from_samples [rise]
		[ mono1, mono2 ].each do |w|
			assert_equal 1, w.channel_count
			assert_equal 2, w.bytes_per_sample
			assert_equal rise.length, w.samples.length
			assert_equal 1, w.channels.length
			assert_equal rise.length, w.channels[0].length
			assert_equal rise, w.samples
			assert_equal rise, w.channels[0]
		end
	end

	def test_create_stereo
		rise1 = -200.step(-100,2).to_a
		rise2 = 7.step(107,2).to_a
		assert_equal rise1.length, rise2.length
		w = W.from_samples [rise1,rise2]
		assert_equal 2, w.channel_count
		assert_equal 2, w.bytes_per_sample
		assert_equal rise1.length*2, w.samples.length
		assert_equal 2, w.channels.length
		assert_equal rise1, w.channels[0]
		assert_equal rise2, w.channels[1]
	end
	
	def test_multi_channel
		channels = (-7..7).map{ |v| [v]*20 }
		multi = W.from_samples channels, channels:channels.length
		assert_equal channels.length, multi.channel_count
		multi.channels.each_with_index do |channel_samples,i|
			assert_equal channels[i], channel_samples
		end
		Dir.chdir(Dir.tmpdir){
			multi.write('multi.wav')
			multi2 = W.from_file('multi.wav')
			multi2.channels.each_with_index do |channel_samples,i|
				assert_equal channels[i], channel_samples
			end
		}
	end

	def	test_pitch
		channels = [ [1]*20, [-1]*20 ]
		stereo  = W.from_samples channels
		stereo2 = stereo.pitch 'c4'
		assert_equal channels.length, stereo2.channel_count

		channels1 = stereo.pitch 'c4', samples_only:true
		assert_equal channels.length, channels1.length

		channels2 = stereo.pitch 'c4', samples_only:true, channels:1
		assert_equal 1, channels2.length

		channels3 = stereo.pitch 'c4', samples_only:true, channels:2
		assert_equal 2, channels3.length
	end
	
	# http://en.wikipedia.org/wiki/Piano_key_frequencies
	def test_frequency_creation
		assert_in_delta 440.000, W.note_frequency('A4')
		assert_in_delta 440.000, W.note_frequency('a4')
		assert_in_delta 880.000, W.note_frequency('A5')
		assert_in_delta 311.127, W.note_frequency('D#4')
		assert_in_delta 261.626, W.note_frequency('C4')
		assert_in_delta  69.296, W.note_frequency('C#2')
		assert_in_delta  69.296, W.note_frequency('Db2')
	end
end
