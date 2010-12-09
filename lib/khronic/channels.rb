class Khronic::Channels
  include Enumerable
  
  def initialize( hash=nil )
    @channels = {}    
    hash.each{ |name,data| add_channel name, data } if hash
  end
  def []( channel_name )
    @channels[channel_name]
  end
  def add_channel( name, data=nil )
    @channels[name] = Khronic::Channel.new data
  end
  def length
    @channels.length
  end
  def each(&block)
    @channels.each(&block)
  end
  def empty?
    @channels.empty?
  end
  def delete( name )
    @channels.delete name
  end
  def to_hash
    Hash[
      @channels.map{ |name,channel|
        [name,channel.to_hash]
      }.flatten
    ]
  end
end

class Khronic::Channel
  LINE_DEFAULTS = {
    'volume' => 100
  }
  attr_reader :lines
  def initialize( data=nil )
    @channel_defaults = data && data['defaults'] || {}
    HashInherit.from LINE_DEFAULTS, @channel_defaults
    @lines = []
    if data && data['lines']
      data['lines'].each do |line_hash_or_nil|
        @lines << line_hash_or_nil
        if line_hash_or_nil
          HashInherit.from @channel_defaults, line_hash_or_nil
        end
      end
    end
  end
  def lines
    @lines ||= []
  end
  def defaults
    @channel_defaults
  end
  def to_hash
    h = {}
    h['defaults'] = @channel_defaults unless @channel_defaults.empty?
    h['lines']    = @lines            unless @lines.empty?
    h
  end
end