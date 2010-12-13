require_relative 'helper'

class TestValidation < MT
  def setup
    @blank = Khronic.new
    @l1    = Khronic.load(L1DOC)
  end
  def test_valid
    assert @l1.valid_level?(1), "The supplied YAML file must validate"
    assert @l1.valid_level_1?
  end
  def test_missing_synth_spec
    @l1.tracks[0].defaults['sample'] = nil
    refute @l1.valid_level_1?, "Validation must ensure a sample reference for each slot"
  end
  def test_missing_synth_reference
    @l1.samples.delete 'synth'
    refute @l1.valid_level_1?, "Validation must find a valid sample for each slot"
  end
  def test_existing_track
    assert_equal 0, @blank.tracks.length
    refute @blank.valid_level_1?, "Valid documents must have at least one track"
  end
  def test_unbalanced_data
    @l1.tracks[0].data.pop
    refute @l1.valid_level_1?, "Validation must ensure that all tracks have the same number of data"
  end
	def test_samples
		@l1.samples['no'] = 'bogus'
		refute @l1.valid_level_1?, "Validation must ensure that all samples have valid files"
	end
end
