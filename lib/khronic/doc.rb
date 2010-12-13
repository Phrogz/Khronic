require 'yaml'

class Khronic
	META_ATTRS = %w[ level title author bpm ]
	DEFAULTS = {
		'bpm' => 120
	}

	META_ATTRS.each do |a|
		define_method(a){ @meta[a] }
		define_method("#{a}="){ |v| @meta[a] = v }
	end
	
	def self.load( source )
		root = nil
		if source.respond_to? :read
			source = source.read
		else
			root = File.dirname(source)
			source = IO.read( source )
		end
		new( source, root )
	end
	
	attr_reader :meta, :samples, :tracks
	def initialize( yaml=nil, root=nil )
		if yaml
			doc = YAML.load(yaml)
			@meta    = doc['meta'] || {}
			@samples = doc['samples']
			@tracks  = Tracks.new doc['tracks']
		else
			@meta    = {}
			@samples = {}
			@tracks  = Tracks.new
		end
		@root = root
		HashInherit.from DEFAULTS, @meta
	end
	
	def add_track( name, data=nil )
		@tracks.add_track name, data
	end
	
	def to_hash
		{
			'meta'    => @meta,
			'samples' => @samples,
			'tracks'  => @tracks.to_hash
		}
	end
	
	def to_yaml(*args)
		to_hash.to_yaml(*args)
	end
end