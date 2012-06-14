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
