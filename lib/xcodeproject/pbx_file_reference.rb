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

require 'xcodeproject/file_node'
require 'xcodeproject/exceptions'

module XcodeProject
	class PBXFileReference < FileNode
		def initialize (root, uuid, data)
			super(root, uuid, data)
		end

		def remove!
			root.build_files(uuid).each do |build_file_obj|
				build_file_obj.remove!
			end
			
			parent.remove_child_uuid(uuid)
			root.remove_object(uuid)
		end

		def self.add(root, path)
			uuid, data = root.add_object(self.create_object_hash(path)) 
			self.new(root, uuid, data)
		end

	private

		def self.create_object_hash (path)
			path = path.to_s
			name = File.basename(path)
			ext = File.extname(path)
			raise ParseError.new("No such file type '#{name}'.") if !FileTypeMap.include?(ext)
			
			data = []
			data << ['isa', 'PBXFileReference']
			data << ['sourceTree', '<group>']
			# data << ['fileEncoding', '4'] # utf-8
			data << ['lastKnownFileType', FileTypeMap[ext]]
			data << ['path', path]
			data << ['name', name] if name != path

			Hash[ data ]
		end

		FileTypeMap = {
			'.h'   => 'sourcecode.c.h',
			'.c'   => 'sourcecode.c.c',
			'.m'   => 'sourcecode.c.objc',
			'.mm'  => 'sourcecode.cpp.objcpp',
			'.hpp' => 'sourcecode.cpp.h',
			'.cpp' => 'sourcecode.cpp.cpp',
			'.cc'  => 'sourcecode.cpp.cpp',
			'.mp3' => 'audio.mp3',
			'.png' => 'image.png',
			'.jpeg' => 'image.jpeg',
			'.jpg'  => 'image.jpeg',
			'.fnt' => 'text',
			'.txt' => 'text'
		}
	end
end
