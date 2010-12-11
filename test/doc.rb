require_relative '_helper'

class TestDoc < MT
  def setup
    @doc = Khronic.new
    @l1  = Khronic.load L1DOC
  end
  def test_defaults
    assert_equal 120, @doc.bpm
    assert_nil @doc.level
    assert_empty @doc.samples
    assert_empty @doc.tracks
  end
  def test_mutable_meta
    @doc.bpm = 160
    assert_equal 160, @doc.bpm
    assert_equal 120, Khronic.new.bpm
  end
  def test_meta
    assert_equal 1.0, @l1.level
    assert_equal "Gavin", @l1.author
    assert_equal "C Major Chord", @l1.title
    assert_equal 80, @l1.bpm
    assert_equal 4, @l1.lines_per_beat
  end
  def test_samples
    assert_equal 3, @l1.samples.length
    assert @l1.samples['synth']
  end
end

