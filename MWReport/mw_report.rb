require "nokogiri"
require 'sax-machine'

##simplify parsing

class FileObject
	include SAXMachine
	element :filename
	element :filesize
	element :mediainfo_recognized
	element :mediainfo_general_format
	element :mediainfo_general_num_video_stream
	element :mediainfo_general_num_audio_stream
	element :mediainfo_general_duration
	element :mediainfo_general_audio_format
	element :mediainfo_general_video_format
	element :mediainfo_general_audio_codec
	element :mediainfo_general_video_codec
end

class MediaObject
	@@total_vid_size = 0
	@@total_vid_duration = 0
	@@total_aud_size = 0
	@@total_aud_duration = 0
	
	def initialize(filename, filesize, format, codec, duration, type)
		@filename = filename
		@filesize = filesize
		@format = format
		@codec = codec
		@duration = duration
		
		if type == "VIDEO"
			@@total_vid_size += filesize.to_i
			@@total_vid_duration += duration.to_i
		end

		if type == "AUDIO"
			@@total_aud_size += filesize.to_i
			@@total_aud_duration += duration.to_i
		end
	end

	def total_vid_duration
		puts "hello"
	end

	def to_s
   		@filename
  	end
end

##parse dfxml
f = File.open("amia.xml")
reader = Nokogiri::XML::Reader(f)

audiofiles = Array.new
videofiles = Array.new

while reader.read
	if reader.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT and reader.name == 'fileobject'
		fo = FileObject.parse(reader.outer_xml)
		if fo.mediainfo_recognized == "true"
			if fo.mediainfo_general_num_video_stream != "0"
				video_object = MediaObject.new(fo.filename, fo.filesize, fo.mediainfo_general_video_format, 
					fo.mediainfo_general_video_codec, fo.mediainfo_general_duration, type = "VIDEO")
				videofiles << video_object
			elsif fo.mediainfo_general_num_audio_stream != "0"
				audio_object = MediaObject.new(fo.filename, fo.filesize, fo.mediainfo_general_audio_format, 
					fo.mediainfo_general_audio_codec, fo.mediainfo_general_duration, type = "AUDIO")
				audiofiles << audio_object
			end
		end
	end
end

##run the report

puts "media walker"
puts "------------\n\n"

puts "number of video files: " + videofiles.size.to_s
puts "total duration of video files: "
puts "total bytesize of video files: "
videofiles.each do |video|
	puts "\t" + video.to_s
end

puts "\nnumber of audio files: " + audiofiles.size.to_s
puts "total duration of audio files: "
puts "total bytesize of audio files: "
audiofiles.each do |audio|
	puts "\t" + audio.to_s
end