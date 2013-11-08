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

	def filename
		@filename
	end

	def filesize
		@filesize
	end

	def duration
		@duration
	end

	def format
		@format
	end

	def codec
   		@codec
  	end
end

def format_milisecs(m)
  secs, milisecs = m.divmod(1000) # divmod returns modulo
  mins, secs = secs.divmod(60)
  hours, mins = mins.divmod(60)

  [hours,mins,secs].map { |e| e.to_s.rjust(2,'0') }.join ':'
end

def format_size(s)
	if(s < 1024)
		s.to_s + " Bytes"
	elsif(s > 1024 && s <= 1024 ** 2)
		(s / (1024.0)).round(2).to_s + " Kilobytes"
	elsif(s > 1024 ** 2 && s <= 1024 ** 3)
		(s / (1024.0 ** 2)).round(2).to_s + " Megabytes"
	elsif(s > 1024 ** 3 &&  s <= 1024 ** 4)
		(s / (1024.0 ** 3)).round(2).to_s " Gigabytes"
	else
		"FAILURE"
	end
end


##parse dfxml
filename = ARGV[0]
#add some usage or filechecking here
f = File.open(filename)
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
				video_object = MediaObject.new(fo.filename, fo.filesize.to_i, fo.mediainfo_general_video_format, 
					fo.mediainfo_general_video_codec, fo.mediainfo_general_duration.to_i, type = "VIDEO")
				videofiles << video_object
				total_vid_size += fo.filesize.to_i
				total_vid_duration += fo.mediainfo_general_duration.to_i
			elsif fo.mediainfo_general_num_audio_stream != "0"
				audio_object = MediaObject.new(fo.filename, fo.filesize.to_i, fo.mediainfo_general_audio_format, 
					fo.mediainfo_general_audio_codec, fo.mediainfo_general_duration.to_i, type = "AUDIO")
				audiofiles << audio_object
				total_aud_size += fo.filesize.to_i
				total_aud_duration += fo.mediainfo_general_duration.to_i
			end
		end
	end
end

##run the report
output = File.new("mediawalker.html", "w+")
output.write("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">")
output.write("<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-type\" content=\"text/html;charset=UTF-8\"/><title>media walker report</title><link href=\"bootstrap.min.css\" rel=\"stylesheet\"/></head><body><div class='container'>")
output.write("<h1>media walker report</h1>")
output.write("<h3>Video Files</h3>")
output.write("<h4>number of files: " + videofiles.size.to_s + "</h4>")
output.write("<h4>duration of files: " + format_milisecs(total_vid_duration) + "</h4>")
output.write("<h4>bytesize of files: " + format_size(total_vid_size) + "</h4>")
output.write("<h3>inventory</h3>")
output.write("<table class=\"table table-bordered\"><thead><tr><th>file</th><th>size</th><th>duration</th><th>format</th><th>codec</th></tr></thead><tbody>")
videofiles.each do |video|
	output.write("<tr>")
		output.write("<td>" + video.filename + "</td>")
		output.write("<td>" + format_size(video.filesize) + "</td>")
		output.write("<td>" + format_milisecs(video.duration.to_i) + "</td>")
		output.write("<td>" + video.format + "</td>")
		output.write("<td>" + video.codec + "</td>")
	output.write("</tr>")
end
output.write("</tbody></table>")

output.write("<br /><br />")

output.write("<h3>Audio Files</h3>")
output.write("<h4>number of files: " + videofiles.size.to_s + "</h4>")
output.write("<h4>duration of files: " + format_milisecs(total_aud_duration) + "</h4>")
output.write("<h4>bytesize of files: " + format_size(total_aud_size) + "</h4>")
output.write("<h3>inventory</h3>")
output.write("<table class=\"table table-bordered\"><thead><tr><th>file</th><th>size</th><th>duration</th><th>format</th><th>codec</th></tr></thead><tbody>")
audiofiles.each do |audio|
	output.write("<tr>")
		output.write("<td>" + audio.filename + "</td>")
		output.write("<td>" + format_size(audio.filesize)  + "</td>")
		output.write("<td>" + format_milisecs(audio.duration.to_i) + "</td>")
		output.write("<td>" + audio.format + "</td>")
		output.write("<td>" + audio.codec + "</td>")
	output.write("</tr>")
end
output.write("</tbody></table>")

output.write("</div><script type=\"text/javascript\" src=\"bootstrap.min.js\"></script></body></html>")
output.close()