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

module XcodeProject
	class PBXBuildFile < Node
		attr_reader :file_ref

		def initialize (root, uuid, data)
			super(root, uuid, data)

			@file_ref = data['fileRef']
		end

		def file_ref
			root.object!(@file_ref)
		end

		def remove!
			root.project.targets.each {|target| target.remove_source(self) }
			root.remove_object(uuid)
		end

		def self.add(root, file_ref_uuid)
			uuid, data = root.add_object(self.create_object_hash(file_ref_uuid)) 
			self.new(root, uuid, data)
		end

	private

		def self.create_object_hash (file_ref_uuid)
			data = []
			data << ['isa', 'PBXBuildFile']
			data << ['fileRef', file_ref_uuid]
			
			Hash[ data ]
		end
	end
end
