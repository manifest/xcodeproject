#--
# Copyright 2012 by Andrey Nesterov (ae.nesterov@gmail.com)
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

require 'xcodeproject/xc_build_configuration'
require 'xcodeproject/pbx_native_target'
require 'xcodeproject/pbx_project'
require 'xcodeproject/pbx_group'
require 'xcodeproject/build_phase_node'
require 'xcodeproject/uuid_generator'
require 'xcodeproject/exceptions'
require 'xcodeproject/extend/string'
require 'xcodeproject/extend/array'
require 'xcodeproject/extend/hash'

module XcodeProject
	class RootNode
		def initialize (data, wd)
			@data, @wd = data, Pathname.new(wd)

			@objects = data['objects']
			@uuid_generator = UUIDGenerator.new
		end

		def project
			find_object!('PBXProject')
		end
	
		def build_files (file_ref_uuid)
			find_objects('PBXBuildFile', {'fileRef' => file_ref_uuid})
		end
		
		def object (uuid)
			data = @objects[uuid]
			XcodeProject.const_get(data['isa']).new(self, uuid, data) unless data.nil?
		end

		def object! (uuid)
			obj = object(uuid)
			raise ParseError.new("Object with uuid = #{uuid} not found.") if obj.nil?; obj
		end

		def select_objects
			objs = @objects.select {|uuid, data| yield uuid, data }
			objs.map {|uuid, data| object(uuid) }
		end

		def find_objects (isa, hash = Hash.new)
			hash.merge!(Hash[ 'isa',  isa ])
			select_objects {|uuid, data| data.values_at(*hash.keys) == hash.values }
		end

		def find_objects! (isa, hash = Hash.new)
			objs = find_objects(isa, hash)
			raise ParseError.new("Object with isa = #{isa} and #{hash} not found.") if objs.empty?; objs
		end
		
		def find_object (isa, hash = Hash.new)
			find_objects(isa, hash).first
		end

		def find_object! (isa, hash = Hash.new)
			obj = find_object(isa, hash)
			raise ParseError if obj.nil?; obj
		end

		def find_object2 (isa, h1 = Hash.new, h2 = Hash.new)
			obj = find_object(isa, h1)
			obj.nil? ? find_object(isa, h2) : obj
		end

		def find_object2! (isa, h1 = Hash.new, h2 = Hash.new)
			obj = find_object2(isa, h1, h2)
			raise ParseError if obj.nil?; obj
		end

		def add_object (data)
			@objects.merge!(Hash[ uuid = generate_object_uuid, data ]); [uuid, data]
		end

		def remove_object (uuid)
			@objects.delete(uuid)
		end

		def absolute_path (path)
			path = Pathname.new(path)
			path = path.absolute? ? path : @wd.join(path)
			path.cleanpath
		end

		def generate_object_uuid
			@uuid_generator.generate
		end

		def to_plist (fmtr = Formatter.new)
			@data.to_plist
		end
	end
end
