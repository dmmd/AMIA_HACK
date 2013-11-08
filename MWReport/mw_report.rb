require "nokogiri"
require 'sax-machine'

##simplify parsing

class FileObject
	include SAXMachine
	element :filename
	element :mediainfo_recognized
	element :mediainfo_general_format
	element :mediainfo_general_num_video_stream
	element :mediainfo_general_num_audio_stream
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
				videofiles << (fo.filename.to_s + "\t" + fo.mediainfo_general_format.to_s)
			elsif fo.mediainfo_general_num_audio_stream != "0"
				audiofiles << (fo.filename.to_s + "\t" + fo.mediainfo_general_format.to_s)	
			end
		end
	end
end

##run the report

puts "media walker"
puts "------------\n\n"

puts "number of video files: " + videofiles.size.to_s
videofiles.sort.each do |video|
	puts "\t" + video
end

puts "\nnumber of audio files: " + audiofiles.size.to_s
audiofiles.sort.each do |audio|
	puts "\t" + audio
end