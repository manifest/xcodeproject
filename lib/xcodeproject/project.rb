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

require 'xcodeproject/data'
require 'pathname'
require 'find'

module XcodeProject
	class Project
		attr_reader :bundle_path
		attr_reader :file_path
		attr_reader :name

		def self.find (pattern = nil)
			pattern = Pathname.new(pattern.to_s)
			pattern = pattern.join('*.xcodeproj') if pattern.extname != '.xcodeproj'

			Dir[ pattern ].map {|path| self.new(path) }
		end

		def initialize (path)
			path = Pathname.new(path)
			raise FilePathError.new("No such project file '#{path}'.") unless path.exist?

			@bundle_path = path
			@file_path = bundle_path.join('project.pbxproj')
			@name = bundle_path.basename('.*').to_s
		end

		def change
			data = read
			yield data
			write data
		end

		def read
			Data.new(JSON.parse(`plutil -convert json -o - "#{file_path}"`), bundle_path.dirname)
		end

		def write (data)
			File.open(file_path, "w") do |file|
				file.write(data.to_plist)
			end
		end

		def doctor
			change {|data| data.doctor }
		end
	end
end
