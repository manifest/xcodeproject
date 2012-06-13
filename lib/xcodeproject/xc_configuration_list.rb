require 'xcodeproject/node'

module XCodeProject
	class XCConfigurationList < Node
		attr_reader :default_configuration_name
		attr_reader :default_configuration_is_visible

		def initialize (root, uuid, data)
			super(root, uuid, data)

			@default_configuration_name = data['defaultConfigurationName']
			@default_configuration_is_visible = data['defaultConfigurationIsVisible']
		end

		def build_configuration (name)
			build_configurations.select {|obj| obj.name == name }.first
		end

		def build_configurations
			data['buildConfigurations'].map {|uuid| root.object!(uuid) }
		end
	end
end
