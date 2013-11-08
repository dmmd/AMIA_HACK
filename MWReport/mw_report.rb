require "nokogiri"
require 'sax-machine'

module Dfxmlmi
	module Parser
		class FileObject
      		include SAXMachine
      		element :filename
      		element :mediainfo_recognized
      		element :mediainfo_format
      	end
	end
end	


f = File.open("amia.xml")
reader = Nokogiri::XML::Reader(f)
while reader.read
	if reader.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT and reader.name == 'fileobject'
		fo = Dfxmlmi::Parser::FileObject.parse(reader.outer_xml)
		if fo.mediainfo_recognized == "true"
			puts fo.filename.to_s + "\t" + fo.mediainfo_format.to_s
		end
	end
end



