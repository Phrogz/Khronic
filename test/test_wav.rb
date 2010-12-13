require_relative '_helper'
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
end
