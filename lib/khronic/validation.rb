class Khronic
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