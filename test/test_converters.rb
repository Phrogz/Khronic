require_relative '_helper'

class TestL1toL0 < MT
	def test_conversion
		@doc = Khronic.load L1DOC
		wav = @doc.convert_between 1, 0
	end
end
