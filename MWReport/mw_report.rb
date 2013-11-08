require "nokogiri"
require 'sax-machine'

module Dfxmlmi
	module Parser
		class FileObject
      		include SAXMachine
      		element :filename
      		element :mediainfo_recognized
      		element :mediainfo_general_format
      		element :mediainfo_general_num_video_stream
      		element :mediainfo_general_num_audio_stream
      	end
	end
end	


f = File.open("amia.xml")
reader = Nokogiri::XML::Reader(f)

while reader.read
	if reader.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT and reader.name == 'fileobject'
		fo = Dfxmlmi::Parser::FileObject.parse(reader.outer_xml)
		if fo.mediainfo_recognized == "true"
			if fo.mediainfo_general_num_video_stream != "0"
				puts "VIDEO: " + fo.filename.to_s + "\t" + fo.mediainfo_general_format.to_s
			elsif fo.mediainfo_general_num_audio_stream != "0"
				puts "AUDIO: " + fo.filename.to_s + "\t" + fo.mediainfo_general_format.to_s	
			end
		end
	end
end