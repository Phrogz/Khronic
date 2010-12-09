require 'yaml'

class Khronic
  def self.load( source )
    if source.respond_to? :read
      source = source.read
    else
      source = IO.read( source )
    end
    new( source )
  end
  
  %w[ level title author bpm lines_per_beat ].each do |m|
    define_method m do
      value_from_path :meta, m
    end
    define_method "#{m}=" do |val|
      set_via_path val, :meta, m
    end
  end
  
  %w[ samples channels ].each do |m|
    define_method m do
      value_from_path m
    end
  end
  
  def initialize( yaml=nil )
    if yaml
      @doc = YAML.load(yaml)
    else
      @doc = {
        'meta'=>{},
        'samples'=>{},
        'channels'=>{}
      }
    end
  end
  
  private
    def value_from_path *path
      h = @doc
      d = DEFAULTS
      path.each_with_index do |key,i|
        d = d[key.to_s] if d
        h = h[key.to_s] || d
        #TODO: detect invalid path and warn on failure
      end
      h
    end
    def set_via_path( val, *path )
      h = @doc
      path[0..-2].each do |key|
        h = (h[key.to_s] ||= {})
      end
      h[path.last.to_s] = val
    end
  
  DEFAULTS = {
    'meta' => {
      'bpm' => 120
    }
  }
  
end

class Khronic::Channel
  def new( hash )
    @hash = hash
  end
  def levels
    
    
  end
end