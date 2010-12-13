class Khronic
	def files_for_samples
		files = {}
		wav_paths = ['',@root,*meta['wav_paths']].compact
		samples.each do |name,file|
			wav_paths.each do |path|
				path = File.join(path,file)
				if File.exists?(path)
					files[name] = File.expand_path(file)
				end
			end
			warn "Could not find file '#{file}' for sample '#{name}'." unless files[name]
		end	
	end
end

Khronic.to_convert_between 1.0, 0.0 do
	wavs = files_for_samples
	wavs.each do |name,file|
		unless File.exists?( file )
		end
		wavs[name] = s
	end
	if wav_paths = meta['wav_paths']
		
	end
	wavs = Hash[ samples.map{ |n,f| [ n, WAV.from_file( f, meta['wav_paths'] ) ] } ]
	loops_by_sample_and_pitch = Hash.new{ |h,sample| h[sample]={} }
	samples.each do |name,file|
		
	end
end
