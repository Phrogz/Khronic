require_relative '_helper'

class TestDoc < Test
  def setup
    @doc = Khronic.new
  end
  def test_defaults
    assert_equal 120, @doc.bpm
    assert_nil @doc.level
    assert_empty @doc.samples
    assert_empty @doc.channels
  end
  def test_mutable_meta
    @doc.bpm = 160
    assert_equal 160, @doc.bpm
    assert_equal 120, Khronic.new.bpm
  end
end

class TestL1Doc < Test
  def setup
    @doc = Khronic.load('docs/cmajor_l1.yaml')
  end
  def test_meta
    assert_equal 1.0, @doc.level
    assert_equal "Gavin", @doc.author
    assert_equal "C Major Chord", @doc.title
    assert_equal 80, @doc.bpm
    assert_equal 4, @doc.lines_per_beat
  end
  def test_samples
    assert_equal 3, @doc.samples.length
    assert @doc.samples['synth']
  end
end