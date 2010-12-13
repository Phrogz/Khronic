module ArrayLoops
	DEFAULTS = {from:0}
	def loop( opts={} )
		opts  = DEFAULTS.merge(opts)
		start = opts[:from]
		close = start + opts[:for]
		result = []
		while close >= length
			result.concat self[start..-1]
			start = 0
			close -= length
		end
		result.concat self[start...close]
	end
end
