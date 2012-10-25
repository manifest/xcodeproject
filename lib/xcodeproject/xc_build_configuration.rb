#--
# Copyright 2012 by Andrei Nesterov (ae.nesterov@gmail.com)
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
require 'xcodeproject/util/plist_accessor'
require 'rexml/document'

module XcodeProject
	class XCBuildConfiguration < Node
		attr_reader :name
		attr_reader :plist
		attr_accessor :build_settings

		def initialize (root, uuid, data)
			super(root, uuid, data)

			@name = data['name']
			@build_settings = data['buildSettings']
			
			@plist = Util::PListAccessor.new(plist_path)
		end

		def version (type = :major)
			major = @plist.read_property('CFBundleShortVersionString')
			minor = @plist.read_property('CFBundleVersion')

			case type
				when :major ; major
				when :minor ; minor
				when :both  ; major + '.' + minor
				else raise ArgumentError.new('Wrong argument type, expected :major, :minor or :both.')
			end
		end

		def change_version (value, type = :major)
			case type
				when :major ; @plist.write_property('CFBundleShortVersionString', value)
				when :minor ; @plist.write_property('CFBundleVersion', value)
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
			root.absolute_path(@build_settings['INFOPLIST_FILE'])
		end

	end
end
