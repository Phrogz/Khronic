# encoding: ASCII-8BIT

class WAVFile
	PARAM_BYTES = {
		"riff_valid"      => 4,
		"riff_valid"      => 4,
		"riff_chunk_size" => 4,
		"riff_format"     => 4,
		"fmt_chunkID"     => 4,
		"fmt_chunk_size"  => 4,
		"audio_format"    => 2,
		"channel_count"   => 2,
		"sample_rate"     => 4,
		"byte_rate"       => 4,
		"block_align"     => 2,
		"bits_per_sample" => 2,
		"data_chunkID"    => 4,
		"data_chunk_size" => 4,
	}
	
	attr_reader :parameters

	def self.load( in_filename )
		self.new.load( in_filename )
	end

	def from_data( data, channels=2, rate=44100 )
		self.new.fill( data, channels, rate )
	end

	PARAM_BYTES.each do |param,bytes|
		v = bytes==4 ? 'V' : 'v'
		define_method param do
			@parameters[param].unpack(v)[0]
			readable_data param, bytes
		end
		define_method "#{param}=" do |value|
			@parameters[param] = [value].pack(v)
		end
	end

	def initialize
		@parameters = {}
		@parameters["riff_valid"]      = "ERRR" #(4b)wants to be "RIFF"
		@parameters["riff_chunk_size"] = "0"    #(4b)Approx filesize? 36 + data_chunk_size
		@parameters["riff_format"]     = "ERRR" #(4b)Wants to be "WAVE"
		@parameters["fmt_chunkID"]     = "ERRR" #(4b)Wants to be "fmt " <-- note the space
		@parameters["fmt_chunk_size"]  = "0"    #(4b)Chunk Size (fixed?) (16 for uncompressed)
		@parameters["audio_format"]    = "0"    #(2b)Compression format (currently only 1 is supported)
		@parameters["channel_count"]   = "0"    #(2b)(1 == mono) (2 == stereo) (>2 = FU)
		@parameters["sample_rate"]     = "0"    #(4b)22k? 44.1?
		@parameters["byte_rate"]       = "0"    #(4b)Uh, byte rate? wtfever. #Wants to be sample_rate*channel_count*bits_per_sample*8 (supposedly)
		@parameters["block_align"]     = "0"    #(2b)yeah, block align. Did I mumble? (== channel_count*bits_per_sample/8)
		@parameters["bits_per_sample"] = "0"    #(2b)8 bits = 8, 16 bits = 16, etc.
		@parameters["data_chunkID"]    = "ERRR" #(4b)Wants to be "data"
		@parameters["data_chunk_size"] = "0"    #(4b)== NumSamples * NumChannels * BitsPerSample/8 (supposedly)
		@parameters["data_chunk"]      = "0"    #(*b)Read the meat. Read it and weep.
	end

	def readable_data( in_param_string, byte_size )
		if( byte_size == 2 || byte_size == 4)
			the_v = byte_size == 2 ? 'v' : 'V'
			#hot poppin fresh debug action
			puts "Reading: #{in_param_string} as '#{the_v}'" if $DEBUG
			return @parameters[in_param_string].unpack(the_v)[0]
		else
			puts "Bad byte size: #{byte_size}. Should be 2 or 4" if $DEBUG
			return
		end
	end
	
	def checkChunk(in_file)
		return in_file.read(4), in_file.read(4)
	end
	
	def load(filename)
		puts "--Reading File: #{filename}" if $DEBUG
		@name = filename
		File.open(@name,'rb') do |f|
			@parameters["riff_valid"]      = f.read(4)
			@parameters["riff_chunk_size"] = f.read(4)
			@parameters["riff_format"]     = f.read(4)
			until @parameters["fmt_chunkID"] == 'fmt ' && @parameters["data_chunkID"] == 'data'
				the_chunk_type, the_chunk_size = checkChunk( f )
				if the_chunk_type == 'fmt '
					@parameters["fmt_chunkID"]     = the_chunk_type
					@parameters["fmt_chunk_size"]  = the_chunk_size
					@parameters["audio_format"]    = f.read(2)
					warn "Uh oh, not PCM!!! got: #{self.readable_data( "audio_format" , 2 )}\n" if self.readable_data( "audio_format" , 2 ) != 1
					@parameters["channel_count"]   = f.read(2)
					@parameters["sample_rate"]     = f.read(4)
					@parameters["byte_rate"]       = f.read(4)
					@parameters["block_align"]     = f.read(2)
					@parameters["bits_per_sample"] = f.read(2)
				elsif the_chunk_type == 'data'
					@parameters["data_chunkID"] = the_chunk_type
					@parameters["data_chunk_size"] = the_chunk_size
					@parameters["data_chunk"] = f.read(self.readable_data("data_chunk_size", 4))
				else
					#blow past undesireable chunks.
					puts "-Wacky Chunk: #{the_chunk_type}:#{the_chunk_size.unpack('V')[0]}" if $DEBUG
					f.read(the_chunk_size.unpack('V')[0])
				end
			end
		end
		self
	end

	def fill( data, channels=2, rate=44100 )
		bits_per_sample = 16
		@parameters["riff_valid"]       = "RIFF"                          #(4b)wants to be "RIFF"
		@parameters["riff_chunk_size"]  = [(36+data.length)].pack('V')    #Thats the size?
		@parameters["riff_format"]      = "WAVE"                          #(4b)Wants to be "WAVE"
		@parameters["fmt_chunkID"]      = "fmt "                          #(4b)Wants to be "fmt " <-- note the space
		@parameters["fmt_chunk_size"]   = [16].pack('V')                  #(4b)Chunk Size (fixed?) (16 for uncompressed)
		@parameters["audio_format"]     = [1].pack('v')                   #(2b)Compression format (currently only 1 is supported)
		@parameters["channel_count"]    = [channels].pack('v')            #(2b)(1 == mono) (2 == stereo) (>2 = FU)
		@parameters["sample_rate"]      = [rate].pack('V')                #(4b)22k? 44.1?
		@parameters["byte_rate"]        = [rate*channels*16*8].pack('V')  #(4b)Uh, byte rate? wtfever. #Wants to be sample_rate*channel_count*bits_per_sample*8 (supposedly)
		@parameters["block_align"]      = [2*bits_per_sample/8].pack('v') #(2b)yeah, block align. Did I mumble? (== channel_count*bits_per_sample/8)
		@parameters["bits_per_sample"]  = [bits_per_sample].pack('v')     #(2b)8 bits = 8, 16 bits = 16, etc.
		@parameters["data_chunkID"]     = "data"                          #(4b)Wants to be "data"
		@parameters["data_chunk_size"]  = [data.length].pack('V')         #(4b)== NumSamples * NumChannels * BitsPerSample/8 (supposedly)
		@parameters["data_chunk"]       = data                            #(*b)Read the meat. Read it and weep.
		self
	end
	
	# def split( num_slices )
	# 	the_children = []
	# 	counter = 1
	# 	num_slices.times do |new_wave|
	# 		temp_chunk_size = self.readable_data("data_chunk_size", 4)/num_slices
	# 		if temp_chunk_size % 2 != 0
	# 			puts "Adjusting chunk size from #{temp_chunk_size} to #{temp_chunk_size+1}" if $DEBUG
	# 			temp_chunk_size += 1
	# 		end
	# 		new_wav = WAVFile.new( )
	# 		new_wav.name = self.name[/^[^\.]+/]+"-"
	# 		new_wav.name += "0" if counter < 10
	# 		new_wav.name += counter.to_s+".wav"
	# 		new_wav.parameters["riff_valid"] = "RIFF"
	# 		new_wav.parameters["riff_format"] = "WAVE"
	# 		new_wav.parameters["fmt_chunkID"] = "fmt "
	# 		new_wav.parameters["fmt_chunk_size"] = self.parameters["fmt_chunk_size"]
	# 		new_wav.parameters["audio_format"] = self.parameters["audio_format"]
	# 		new_wav.parameters["channel_count"] = self.parameters["channel_count"]
	# 		new_wav.parameters["sample_rate"] = self.parameters["sample_rate"]
	# 		new_wav.parameters["byte_rate"] = self.parameters["byte_rate"]
	# 		new_wav.parameters["block_align"] = self.parameters["block_align"]
	# 		new_wav.parameters["bits_per_sample"] = self.parameters["bits_per_sample"]
	# 		new_wav.parameters["data_chunkID"] = self.parameters["data_chunkID"]
	# 		new_wav.parameters["data_chunk_size"] = [temp_chunk_size].pack('V')
	# 		print("Slice ",counter," data chunk size: ",temp_chunk_size," vs. ",((temp_chunk_size*(counter-1))..((temp_chunk_size*counter)-1)).to_a.length.to_s,"\n") if $DEBUG
	# 		new_wav.parameters["data_chunk"] = self.parameters["data_chunk"][(temp_chunk_size*(counter-1))..((temp_chunk_size*counter)-1)]
	# 		the_children[counter-1] = new_wav
	# 		counter = counter + 1
	# 	end
	# 	return the_children
	# end

	def write( filename )
		puts "--Writing File: #{filename}" if $DEBUG
		File.open( filename, 'wb' ) do |f|
			f.write @parameters["riff_valid"]
			f.write [(36+self.readable_data("data_chunk_size", 4))].pack('V')
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

	def errors
		[]
		@error_string += ":byte rate error"   unless self.readable_data("byte_rate", 4)   == self.readable_data("sample_rate",   4)*self.readable_data("channel_count",   2)*self.readable_data("bits_per_sample", 2)/8
		@error_string += ":block align error" unless self.readable_data("block_align", 2) == self.readable_data("channel_count", 2)*self.readable_data("bits_per_sample", 2)/8
		@error = true if @error_string.length != 0
		@error
	end
	
	def debug
		x = <<-ENDSTRING
		--Start Debug output--
		  Filename: #{@name}
		  Riff valid?: #{@parameters["riff_valid"]}
		  Riff chunk size: #{self.readable_data("riff_chunk_size", 4)}
		  Riff Format: #{@parameters["riff_format"]}
		  fmt chunk ID: #{@parameters["fmt_chunkID"]}
		  fmt chunk size: #{self.readable_data("fmt_chunk_size", 4)}
		  Audio format: #{self.readable_data("audio_format", 2)}
		  Channel count: #{self.readable_data("channel_count", 2)}
		  Sample rate: #{self.readable_data("sample_rate", 4)}
		  Byte rate: #{self.readable_data("byte_rate", 4)}
		  Block align: #{self.readable_data("block_align", 2)}
		  Bits per sample: #{self.readable_data("bits_per_sample", 2)}
		  Data chunk ID: #{@parameters["data_chunkID"]}	
		  Data chunk size: #{self.readable_data("data_chunk_size", 4)}
		--End Debug output--
		ENDSTRING
		x.gsub /^#{x[/\A\s+/]}/o, ''
	end
end
