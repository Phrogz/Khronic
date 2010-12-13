module ArrayLoops
	def loop( opts={} )
		start = opts[:from] || 0
		close = start + (opts[:for] || length)
		result = []
		while close >= length
			result.concat self[start..-1]
			start = 0
			close -= length
		end
		result.concat self[start...close]
	end
end
