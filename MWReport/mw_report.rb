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

  [secs,mins,hours].map { |e| e.to_s.rjust(2,'0') }.join ':'
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
output = File.new("mediawalker.html", "w+")
output.write("<html><head><title>media walker report</title></head><link href=\"bootstrap.min.css\" rel=\"stylesheet\"><body><div class='container'>")
output.write("<h1>media walker report</h1>")
output.write("<h3>Video Files</h2>")
output.write("<h4>number of files: " + videofiles.size.to_s + "</h4>")
output.write("<h4>duration of files: " + format_milisecs(total_vid_duration) + "</h4>")
output.write("<h4>bytesize of files: " + total_vid_size.to_s + "</h4>")
output.write("<h3>inventory</h2>")
output.write("<table class=\"table table-bordered\"><thead><tr><th>file</th><th>size</th><th>duration</th><th>format</th><th>codec</th></tr><tbody>")
videofiles.each do |video|
	output.write("<tr>")
		output.write("<td>" + video.filename + "</td>")
		output.write("<td>" + video.filesize.to_s  + "</td>")
		output.write("<td>" + format_milisecs(video.duration.to_i) + "</td>")
		output.write("<td>" + video.format + "</td>")
		output.write("<td>" + video.codec + "</td>")
	output.write("</tr>")
end
output.write("</tbody></table>")

output.write("<br /><br />")

output.write("<h3>Audio Files</h2>")
output.write("<h4>number of files: " + videofiles.size.to_s + "</h4>")
output.write("<h4>duration of files: " + format_milisecs(total_aud_duration) + "</h4>")
output.write("<h4>bytesize of files: " + total_aud_size.to_s + "</h4>")
output.write("<h3>inventory</h2>")
output.write("<table class=\"table table-bordered\"><thead><tr><th>file</th><th>size</th><th>duration</th><th>format</th><th>codec</th></tr><tbody>")
audiofiles.each do |audio|
	output.write("<tr>")
		output.write("<td>" + audio.filename + "</td>")
		output.write("<td>" + audio.filesize.to_s  + "</td>")
		output.write("<td>" + format_milisecs(audio.duration.to_i) + "</td>")
		output.write("<td>" + audio.format + "</td>")
		output.write("<td>" + audio.codec + "</td>")
	output.write("</tr>")
end

output.write("</div><script src=\"bootstrap.min.js\"></script></body></html>")

=begin


puts "VIDEO FILES"
puts "number of files: " + videofiles.size.to_s
puts "duration of files: " + format_milisecs(total_vid_duration)
puts "bytesize of files: " + total_vid_size.to_s
videofiles.each do |video|
	puts "\t" + video.filename + "\t" + video.filesize.to_s + "\t" + format_milisecs(video.duration.to_i) + "\t" + video.format +  "\t" + video.codec
end

puts "\nAUDIO FILES"
puts "number of files: " + audiofiles.size.to_s
puts "duration of files: " + format_milisecs(total_aud_duration)
puts "bytesize of files: " + total_aud_size.to_s
audiofiles.each do |audio|
	puts "\t" + audio.filename
end

=end