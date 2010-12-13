class Khronic
	@converters_by_versions = {}
	class << self
		attr_reader :converters_by_versions
	end
	def self.to_convert_between( from, to, &block )
		@converters_by_versions[ [from, to] ] = block
	end
	def convert( opts )
		unless converter = self.class.converters_by_versions[ [from, to] ]
			raise "No converter found to go from level #{from} to #{to}" 
		end
		self.instance_eval &converter
	end
end

converters = Dir[File.join File.dirname(__FILE__), 'converters', '*.rb']
require_relative *converters