Khronic.to_convert_between 1, :wav do
	raise "Cannot convert; document is not valid level 1.0 " unless self.valid_level_1?
	files = files_for_samples
	
	output_channels    = self.channels
	lines_per_second   = bpm * (meta['lines_per_beat'] || 4) / 60.0
	samples_per_line   = (meta['rate'] / lines_per_second).round
	
	wavs = Hash[ files.map{ |n,f| [ n, WAV.from_file(f) ] } ]

	loop_channels_by_sample_and_pitch = Hash.new do |h,sample|
		h[sample]=Hash.new do |h,pitch|
			wav_channels = wavs[sample].pitch( pitch, samples_only:true, channels:output_channels )
			wav_channels.each{ |channel| channel.extend ArrayLoops }
			h[pitch] = wav_channels
		end
	end

	blank_slot = (1..output_channels).map{ [0] * samples_per_line }

	track_samples = tracks.map do |name,track|
		last_sample = nil
		index = 0
		track.data.map do |slot|
			sample_name = slot && slot['sample']
			if sample_name != last_sample
				index = 0
				last_sample = sample_name
			end
			if sample_name
				channels = loop_channels_by_sample_and_pitch[sample_name][slot['pitch']]
				channels.map{ |channel|
					data = channel.loop from:index, for:samples_per_line
					data.map!{ |s| s*slot['volume']/100.0 } if slot['volume'] < 100
					index += samples_per_line
					data
				}
			else
				blank_slot
			end
		end.transpose.map{ |x| x.flatten }
	end.transpose
	
	channels = track_samples.map{ |channel|
		channel.shift.zip( *channel ).map{ |samples|
			sum = 0
			samples.each{ |s| sum += s }
			sum / samples.length
		}
	}

	Khronic::WAV.from_samples channels
end
