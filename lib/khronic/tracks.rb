class Khronic::Tracks
	include Enumerable
	
	def initialize( hash=nil )
		@tracks = {}    
		hash.each{ |name,data| add_track name, data } if hash
	end
	def []( track_name )
		@tracks[track_name]
	end
	def add_track( name, data=nil )
		@tracks[name] = Khronic::Track.new data
	end
	def length
		@tracks.length
	end
	def each(&block)
		@tracks.each(&block)
	end
	def empty?
		@tracks.empty?
	end
	def delete( name )
		@tracks.delete name
	end
	def to_hash
		Hash[
			@tracks.map{ |name,track|
				[name,track.to_hash]
			}.flatten
		]
	end
end

class Khronic::Track
	LINE_DEFAULTS = {
		'volume' => 100
	}
	attr_reader :data
	def initialize( data=nil )
		@track_defaults = data && data['defaults'] || {}
		HashInherit.from LINE_DEFAULTS, @track_defaults
		@data = []
		if data && data['data']
			data['data'].each do |hash_or_nil|
				@data << hash_or_nil
				if hash_or_nil
					HashInherit.from @track_defaults, hash_or_nil
				end
			end
		end
	end
	def defaults
		@track_defaults
	end
	def to_hash
		h = {}
		h['defaults'] = @track_defaults unless @track_defaults.empty?
		h['data']     = @data           unless @data.empty?
		h
	end
end