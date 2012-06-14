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
			data << ['fileEncoding', '4'] # utf-8
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
			'.cc'  => 'sourcecode.cpp.cpp'
		}
	end
end
