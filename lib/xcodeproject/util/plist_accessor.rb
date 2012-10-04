require 'pathname'

module XcodeProject
	class PListAccessor
		attr_accessor :file_path

		def initialize (file_path)
			@file_path = Pathname.new(file_path)
		end

		def read_property (key)
			file = File.new(@file_path)
			doc = REXML::Document.new(file)
			
			doc.elements.each("plist/dict/key") do |e| 
				 return e.next_element.text if e.text == key
			end
			nil
		end

		def write_property (key, value)
			file = File.new(@file_path)
			doc = REXML::Document.new(file)

			doc.elements.each("plist/dict/key") do |e|
				e.next_element.text = value if e.text == key
			end

			formatter = REXML::Formatters::Default.new
			File.open(plist_path, 'w') do |data|
				formatter.write(doc, data)
			end
			nil
		end
	end
end

