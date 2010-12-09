require_relative '_helper'

class TestValidation < MT
  def setup
    @blank = Khronic.new
    @l1  = Khronic.load(L1DOC)
  end
  def test_valid
    assert @l1.valid_level?(1)
    assert @l1.valid_level_1?
  end
  def test_missing_synth_spec
    @l1.channels[0].defaults['sample'] = nil
    refute @l1.valid_level_1?, "Validation must ensure a sample reference for each slot"
  end
  def test_missing_synth_reference
    @l1.samples.delete 'synth'
    refute @l1.valid_level_1?, "Validation must find a valid sample for each slot"
  end
  def test_existing_channel
    assert_equal 0, @blank.channels.length
    refute @blank.valid_level_1?, "Valid documents must have at least one channel"
  end
  def test_unbalanced_lines
    @l1.channels[0].lines.pop
    refute @l1.valid_level_1?, "Validation must ensure that all channels have the same number of lines"
  end
end
