require 'pathname'

module XcodeProject
	module Util
		class PListAccessor
			attr_accessor :file_path

			def initialize (file_path)
				@file_path = Pathname.new(file_path)
			end

			def read_property (key, hash = nil)
				file = File.new(@file_path)
				doc = REXML::Document.new(file)
			
				result = nil
				doc.elements.each("plist/dict/key") do |e| 
					 result = e.next_element.text if e.text == key
				end
				result = replace_placeholders(result, hash) unless hash.nil? unless result.nil?
				result
			end

			def write_property (key, value)
				file = File.new(@file_path)
				doc = REXML::Document.new(file)

				doc.elements.each("plist/dict/key") do |e|
					e.next_element.text = value if e.text == key
				end

				formatter = REXML::Formatters::Default.new
				@file_path.open('w') do |data|
					formatter.write(doc, data)
				end
				nil
			end

			def replace_placeholders (text, hash)
				pattern = /\$\{[^\}]+\}/
				return text if text.scan(pattern).empty?

				result = text.gsub(pattern) do |ph|
					data = ph.match /\A\$\{(\w+)/
					raise ParseError.new("Unknown placeholder type: '#{ph}'.") if data.to_a.size < 2

					value = hash[data[1]]
					raise ArgumentError.new("Replacement value for '#{ph}' placeholder isn't represented in the 'hash'.") if value.nil?
					value
				end

				replace_placeholders(result, hash)
			end

		end
	end
end

