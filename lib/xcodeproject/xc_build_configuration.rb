#--
# The MIT License
#
# Copyright (c) 2012-2014 Andrei Nesterov <ae.nesterov@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#++

require 'xcodeproject/node'
require 'rexml/document'

module XcodeProject
	class XCBuildConfiguration < Node
		attr_reader :name
		attr_accessor :build_settings

		def initialize (root, uuid, data)
			super(root, uuid, data)

			@name = data['name']
			@build_settings = data['buildSettings']
		end

		def version (type = :major)
			major = read_property('CFBundleShortVersionString')
			minor = read_property('CFBundleVersion')

			case type
				when :major ; major
				when :minor ; minor
				when :both  ; major + '.' + minor
				else raise ArgumentError.new('Wrong argument type, expected :major, :minor or :both.')
			end
		end

		def change_version (value, type = :major)
			case type
				when :major ; write_property('CFBundleShortVersionString', value)
				when :minor ; write_property('CFBundleVersion', value)
				else raise ArgumentError.new('Wrong argument type, expected :major or :minor.')
			end
		end

		def increment_version (type = :major)
			cv = version(type)
			nv = cv.nil? ? '0' : cv.next

			change_version(nv, type)
		end

	private

		def plist_path
			root.absolute_path(build_settings['INFOPLIST_FILE'])
		end

		def read_property (key)
			file = File.new(plist_path)
			doc = REXML::Document.new(file)
			
			doc.elements.each("plist/dict/key") do |e| 
				 return e.next_element.text if e.text == key
			end
			nil
		end

		def write_property (key, value)
			file = File.new(plist_path)
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
