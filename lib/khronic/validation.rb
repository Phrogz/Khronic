class Khronic
	def files_for_samples
		files = {}
		wav_paths = [@root,''].compact
		meta['wav_paths'].each do |path|
			wav_paths.unshift path
			wav_paths.unshift File.join(@root,path) if @root
		end if meta['wav_paths']
		samples.each do |name,file|
			wav_paths.each do |path|
				path = File.join(path,file)
				if File.exists?(path)
					files[name] = File.expand_path(path)
					break
				end
			end
			# warn "Could not find file '#{file}' for sample '#{name}'." unless files[name]
		end
		files
	end

	def valid_level?( n )
		send "valid_level_#{n}?"
	end
	
	def valid_level_1?
		# Need at least one track
		return false unless tracks.length>0
		
		return false unless tracks.all?{ |name,track| track.data.is_a? Array }

		data = tracks.map{ |name,track| track.data.length }.uniq    
		unless data.length==1
			warn "Disparate numbers of data points: #{data.inspect}" if $DEBUG
			return false
		end
		
		files = files_for_samples
		missing_files = samples.select{ |name,file| !files.has_key? name }
		unless missing_files.empty?
			warn "Could not find the following samples/files:#{missing_files}"
			return false
		end
		
		tracks.each do |name,track|
			track.data.each do |slot|
				if slot && !samples[slot['sample']]
					warn "Missing sample '#{slot['sample']}'" if $DEBUG
					return false
				end
			end
		end
		
		return true
	end
end