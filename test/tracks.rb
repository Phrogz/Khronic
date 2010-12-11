require_relative '_helper'

class TestTracks < MT
  def setup
    @doc = Khronic.new
  end
  def test_adding
    assert_empty @doc.tracks, "Documents start with no tracks"
    assert_equal 0, @doc.tracks.length
    bass = @doc.add_track 'bassline'
    assert_equal 1, @doc.tracks.length
    assert_equal bass, @doc.tracks['bassline']
  end
  def test_iteration
    bass = @doc.add_track 'bassline'
    beat = @doc.add_track 'drums'
    assert_equal 2, @doc.tracks.length
    seen = {}
    @doc.tracks.each do |name,track|
      seen[name] = track
    end
    assert_equal beat, seen['drums']
  end
  def test_serialization
    assert @doc.to_yaml[/tracks:/], "Docs without tracks still show them in the YAML"
    assert_nil @doc.to_yaml[/lines:/], "Docs without tracks should not have lines in the YAML"
  end
end

class TestLines < MT
  def setup
    @doc = Khronic.new
    @l1  = Khronic.load L1DOC
    @lead = @doc.add_track 'Melody'
  end
  def test_loaded_lines
    assert_equal 20, @l1.tracks[0].lines.length
  end
  def test_adding_lines
    assert_empty @lead.lines
    assert_equal 0, @lead.lines.length
  end
  def test_line_serialization
    assert_nil @doc.to_yaml[/lines:/], "Docs without tracks should not have lines in the YAML"
    beat = @doc.add_track 'drums'
    assert_nil @doc.to_yaml[/lines:/], "tracks without lines should not have lines in the YAML"
  end  
end
