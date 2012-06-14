require 'xcodeproject/node'

module XcodeProject
	class PBXProject < Node
		attr_reader :main_group
		attr_reader :product_ref_group
		attr_reader :project_dir_path
		attr_reader :compatibility_version
		attr_reader :development_region
		attr_reader :know_regions
		attr_reader :attributes

		def initialize (root, uuid, data)
			super(root, uuid, data)

			@main_group = root.object!(data['mainGroup'])
			@product_ref_group = root.object!(data['productRefGroup'])
			@project_dir_path = data['projectDirPath']
			@compatibility_version = data['compatibilityVersion']
			@development_region = data['developmentRegion']
			@know_regions = data['knownRegions']
			@attributes = data['attributes']
		end

		def targets
			data['targets'].map {|uuid| root.object!(uuid)}
		end

		def target (name)
			root.find_object('PBXNativeTarget', {'name' => name})
		end
	end
end
