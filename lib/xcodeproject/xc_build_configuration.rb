require 'xcodeproject/node'

module XcodeProject
	class XCBuildConfiguration < Node
		attr_reader :name
		attr_accessor :build_settings

		def initialize (root, uuid, data)
			super(root, uuid, data)

			@name = data['name']
			@build_settings = data['buildSettings']
		end
	end
end
