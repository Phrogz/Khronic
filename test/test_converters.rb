require_relative 'helper'

class TestL1toL0 < MT
	def test_conversion
		@doc = Khronic.load L1DOC
		wav = @doc.convert_to :wav
		assert_kind_of Khronic::WAV, wav
	end
end
