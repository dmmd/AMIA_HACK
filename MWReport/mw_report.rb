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

#object for creating inventory table
class MediaObject	
	def initialize(filename, filesize, format, codec, duration, type)
		@filename = filename
		@filesize = filesize
		@format = format
		@codec = codec
		@duration = duration
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
total_vid_duration = 0
total_aud_duration = 0
total_vid_size = 0
total_aud_size = 0

while reader.read
	if reader.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT and reader.name == 'fileobject'
		fo = FileObject.parse(reader.outer_xml)
		if fo.mediainfo_recognized == "true"
			if fo.mediainfo_general_num_video_stream != "0"
				video_object = MediaObject.new(fo.filename, fo.filesize, fo.mediainfo_general_video_format, 
					fo.mediainfo_general_video_codec, fo.mediainfo_general_duration, type = "VIDEO")
				videofiles << video_object
				total_vid_size += fo.filesize.to_i
				total_vid_duration += fo.mediainfo_general_duration.to_i
			elsif fo.mediainfo_general_num_audio_stream != "0"
				audio_object = MediaObject.new(fo.filename, fo.filesize, fo.mediainfo_general_audio_format, 
					fo.mediainfo_general_audio_codec, fo.mediainfo_general_duration, type = "AUDIO")
				audiofiles << audio_object
				total_aud_size += fo.filesize.to_i
				total_aud_duration += fo.mediainfo_general_duration.to_i
			end
		end
	end
end

##run the report
puts "media walker"
puts "------------\n\n"

puts "number of video files: " + videofiles.size.to_s
puts "total duration of video files: " + total_vid_duration.to_s
puts "total bytesize of video files: " + total_vid_size.to_s
videofiles.each do |video|
	puts "\t" + video.to_s
end

puts "\nnumber of audio files: " + audiofiles.size.to_s
puts "total duration of audio files: " + total_aud_duration.to_s
puts "total bytesize of audio files: " + total_aud_size.to_s
audiofiles.each do |audio|
	puts "\t" + audio.to_s
end