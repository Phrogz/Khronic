require_relative '_helper'

class TestChannel < MT
  def setup
    @doc = Khronic.new
  end
  def test_adding
    assert_empty @doc.channels, "Documents start with no channels"
    assert_equal 0, @doc.channels.length
    bass = @doc.add_channel 'bassline'
    assert_equal 1, @doc.channels.length
    assert_equal bass, @doc.channels['bassline']
  end
  def test_iteration
    bass = @doc.add_channel 'bassline'
    beat = @doc.add_channel 'drums'
    assert_equal 2, @doc.channels.length
    seen = {}
    @doc.channels.each do |name,channel|
      seen[name] = channel
    end
    assert_equal beat, seen['drums']
  end
  def test_serialization
    assert @doc.to_yaml[/channels:/], "Docs without channels still show them in the YAML"
    assert_nil @doc.to_yaml[/lines:/], "Docs without channels should not have lines in the YAML"
  end
end

class TestLines < MT
  def setup
    @doc = Khronic.new
    @lead = @doc.add_channel 'Melody'
  end
  def test_adding
    assert_empty @lead.lines
    assert_equal 0, @lead.lines.length
  end
  def test_serialization
    assert_nil @doc.to_yaml[/lines:/], "Docs without channels should not have lines in the YAML"
    beat = @doc.add_channel 'drums'
    assert_nil @doc.to_yaml[/lines:/], "Channels without lines should not have lines in the YAML"
  end  
end
