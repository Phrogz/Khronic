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
end

class Khronic::Channel
  LINE_DEFAULTS = {
    
  }
  def initialize( data=nil )
  end
  def lines
    @lines ||= []
  end
  def defaults
    @line_defaults ||= {}
  end
end