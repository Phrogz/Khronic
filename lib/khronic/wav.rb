# encoding: ASCII-8BIT

class WAV
	# Used by the #fill and #generate
	DEFAULT_OPTIONS = {
		:channels        => 2,
		:rate            => 441000,
		:bits_per_sample => 16
	}

	# Create a wav from a file on disk.
	# Equivalent to `WAV.new.load( filename )`.
	def self.from_file( filename )
		self.new.load( filename )
	end

	# Equivalent to `WAV.new.generate( samples, options )`.
	# See #generate for more details.
	def self.from_samples( samples, options={} )
		self.new.generate( samples, options )
	end

	# Equivalent to `WAV.new.fill( data, options )`.
	# See #fill for more details.
	def self.from_data( data, options={} )
		self.new.fill( data, options )
	end

	#:nodoc:
	# Used to generate real accessors
	BYTE_PARAMS = {
		"riff_chunk_size" => 4,
		"fmt_chunk_size"  => 4,
		"audio_format"    => 2,
		"channel_count"   => 2,
		"sample_rate"     => 4,
		"byte_rate"       => 4,
		"block_align"     => 2,
		"bits_per_sample" => 2,
		"data_chunk_size" => 4,
	}

	# attr_* are for RDoc; replaced with proper readers/writers below

	# 36 + data_chunk_size
	attr_reader :riff_chunk_size
	attr_accessor :fmt_chunk_size

	# Only format 1 is currently supported
	attr_accessor :audio_format

	# 1 for mono, 2 for stero, 3+ for multi-channel audio
	attr_accessor :channel_count

  # 441000, 22000, etc.
	attr_accessor :sample_rate
	
  # Automatically set to be sample_rate*channel_count*bytes_per_sample
	attr_reader :byte_rate

	# bits_per_sample padded up to the nearest byte
	attr_reader :bytes_per_sample

	# channel_count * bytes_per_sample
	attr_reader :block_align

	# 8 for 8 bits, 16 for 16 bits, etc.
	# Only tested for multiples of 8.
	attr_accessor :bits_per_sample

	# The number of bytes in the data block
	attr_reader :data_chunk_size

	# The raw data of the wav; set using #generate or #fill
	attr_reader :data

	BYTE_PARAMS.each do |param,bytes|
		v = bytes==4 ? 'V' : 'v'
		define_method param do
			@parameters[param].unpack(v)[0]
		end
		if %w[ sample_rate channel_count bits_per_sample ].include?(param)
			define_method "#{param}=" do |value|
				@parameters[param] = [value].pack(v)
				byte_rate   = sample_rate*channel_count*bytes_per_sample
				block_align = channel_count * bytes_per_sample
			end
		else
			define_method "#{param}=" do |value|
				@parameters[param] = [value].pack(v)
			end
		end
	end
	alias_method :channels, :channel_count
	alias_method :channels=, :channel_count=
	private :byte_rate=, :block_align=, :data_chunk_size=, :riff_chunk_size=
	
	%w[ riff_valid riff_format fmt_chunkID data_chunkID ].each do |param|
		define_method(param){ @parameters[param] }
		define_method("#{param}="){ |v| @parameters[param]=v }
	end

	#:nodoc:
	def bytes_per_sample
		((bits_per_sample / 8.0).ceil * 8).to_i
	end

	#:nodoc:
	def data
		@parameters["data_chunk"]
	end

	def initialize
		# Treat blind reads into unset values as an invalid sigil
		@parameters = Hash.new{-1}
		@parameters["riff_valid"]       = "RIFF" #(4b)wants to be "RIFF"
		@parameters["riff_format"]      = "WAVE" #(4b)Wants to be "WAVE"
		@parameters["fmt_chunkID"]      = "fmt " #(4b)Wants to be "fmt " <-- note the space
		@parameters["data_chunkID"]     = "data" #(4b)Wants to be "data"
	end

	# Replace the contents of this wav from a file on disk.
	def load( filename )
		puts "--Reading File: #{filename}" if $DEBUG
		File.open(filename,'rb') do |f|
			@parameters["riff_valid"]      = f.read(4)
			@parameters["riff_chunk_size"] = f.read(4)
			@parameters["riff_format"]     = f.read(4)
			until @parameters["fmt_chunkID"] == 'fmt ' && @parameters["data_chunkID"] == 'data'
				the_chunk_type = f.read(4)
				the_chunk_size = f.read(4)
				if the_chunk_type == 'fmt '
					@parameters["fmt_chunkID"]     = the_chunk_type
					@parameters["fmt_chunk_size"]  = the_chunk_size
					@parameters["audio_format"]    = f.read(2)
					warn "Uh oh, not PCM!!! got: #{audio_format}" if audio_format != 1
					@parameters["channel_count"]   = f.read(2)
					@parameters["sample_rate"]     = f.read(4)
					@parameters["byte_rate"]       = f.read(4)
					@parameters["block_align"]     = f.read(2)
					@parameters["bits_per_sample"] = f.read(2)
				elsif the_chunk_type == 'data'
					@parameters["data_chunkID"]    = the_chunk_type
					@parameters["data_chunk_size"] = the_chunk_size
					@parameters["data_chunk"]      = f.read(data_chunk_size)
				else
					#blow past undesireable chunks.
					puts "-Wacky Chunk: #{the_chunk_type}:#{the_chunk_size.unpack('V')[0]}" if $DEBUG
					f.read(the_chunk_size.unpack('V')[0])
				end
			end
		end
		self
	end

	# `data` must be a flat array of samples in byte-padded, little-endian format
	# as found in an existing wav file. All other parameters will be set accordingly.
	def fill( data, options={} )
		options = DEFAULT_OPTIONS.merge(options)
		bps      = options[:bits_per_sample]
		rate     = options[:rate]
		channels = options[:channels]
		@parameters["riff_valid"]       = "RIFF"                          #(4b)wants to be "RIFF"
		@parameters["riff_chunk_size"]  = [(36+data.length)].pack('V')    #Thats the size?
		@parameters["riff_format"]      = "WAVE"                          #(4b)Wants to be "WAVE"
		@parameters["fmt_chunkID"]      = "fmt "                          #(4b)Wants to be "fmt " <-- note the space
		@parameters["fmt_chunk_size"]   = [16].pack('V')                  #(4b)Chunk Size (fixed?) (16 for uncompressed)
		@parameters["audio_format"]     = [1].pack('v')                   #(2b)Compression format (currently only 1 is supported)
		@parameters["channel_count"]    = [channels].pack('v')            #(2b)(1 == mono) (2 == stereo) (>2 = FU)
		@parameters["sample_rate"]      = [rate].pack('V')                #(4b)22k? 44.1?
		@parameters["byte_rate"]        = [rate*channels*16*8].pack('V')  #(4b)Uh, byte rate? wtfever. #Wants to be sample_rate*channel_count*bits_per_sample*8 (supposedly)
		@parameters["block_align"]      = [channels*bps/8].pack('v')      #(2b)yeah, block align. Did I mumble? (== channel_count*bits_per_sample/8)
		@parameters["bits_per_sample"]  = [bps].pack('v')                 #(2b)8 bits = 8, 16 bits = 16, etc.
		@parameters["data_chunkID"]     = "data"                          #(4b)Wants to be "data"
		@parameters["data_chunk_size"]  = [data.length].pack('V')         #(4b)== NumSamples * NumChannels * BitsPerSample/8 (supposedly)
		@parameters["data_chunk"]       = data                            #(*b)Read the meat. Read it and weep.
		self
	end
	
	# Fill the wav file from raw integer values.
	# 
	# `samples` may be either an array samples (mono),
	# an array of two (or more) arrays samples (stereo+),
	# or an array of pre-interleaved values (stereo+).
	#
	# If the array is already interleaved, you must pass as options the values:
	#     {channels:2, interleaved:true} # Or however many channels you have.
	#
	# If the array is not interleaved, the method will automatically detect
	# how many channels you have.
	#
	# If you do not supply a `:rate` option the value from DEFAULT_OPTIONS is used.
	def generate( samples, options={} )
		unless options[:channels]
			# 18 channels ought to be enough for anyone
			# http://www.microsoft.com/whdc/device/audio/multichaud.mspx
			options[:channels] = samples.length > 18 ? 1 : samples.length
		end
		unless options[:interleaved] || options[:channels]==1
			samples = samples.first.zip( *samples[1..-1] )
		end
		fill( samples.flatten.pack('v*'), options )
	end
	
	# Write the WAV file to disk.
	def write( filename )
		puts "--Writing File: #{filename}" if $DEBUG
		File.open( filename, 'wb' ) do |f|
			f.write @parameters["riff_valid"]
			f.write [(36+data_chunk_size)].pack('V')
			f.write @parameters["riff_format"]
			f.write @parameters["fmt_chunkID"]
			f.write @parameters["fmt_chunk_size"]
			f.write @parameters["audio_format"]
			f.write @parameters["channel_count"]
			f.write @parameters["sample_rate"]
			f.write @parameters["byte_rate"]
			f.write @parameters["block_align"]
			f.write @parameters["bits_per_sample"]
			f.write @parameters["data_chunkID"]
			f.write @parameters["data_chunk_size"]
			f.write @parameters["data_chunk"]
		end
	end

	# Detect if byte_rate and block_align are valid
	def errors
		e = []
		e << "byte rate error"   unless byte_rate   == sample_rate*channel_count*bits_per_sample/8
		e << "block align error" unless block_align == channel_count*bits_per_sample/8
		e.join(',') unless e.empty?
	end
	
	def inspect
		x = <<-ENDSTRING
		--WAV--
		  Riff valid?: #{@parameters["riff_valid"]}
		  Riff chunk size: #{riff_chunk_size}
		  Riff Format: #{@parameters["riff_format"]}
		  fmt chunk ID: #{@parameters["fmt_chunkID"]}
		  fmt chunk size: #{fmt_chunk_size}
		  Audio format: #{audio_format}
		  Channel count: #{channel_count}
		  Sample rate: #{sample_rate}
		  Byte rate: #{byte_rate}
		  Block align: #{block_align}
		  Bits per sample: #{bits_per_sample}
		  Data chunk ID: #{@parameters["data_chunkID"]}	
		  Data chunk size: #{data_chunk_size}
		ENDSTRING
		x.gsub /^#{x[/\A\s+/]}/o, ''
	end

	# How many samples there are (or should be) per channel
	def samples
		data_chunk_size / channels / bytes_per_sample
	end

end
