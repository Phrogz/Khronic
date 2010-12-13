module ArrayLoops
	def loop( opts={} )
		l = self.length
		start = (opts[:from] || 0 ) % l
		close = start + (opts[:for] || l)
		result = []
		while close >= l
			result.concat self[start..-1]
			start = 0
			close -= l
		end
		result.concat self[start...close]
	end
end
