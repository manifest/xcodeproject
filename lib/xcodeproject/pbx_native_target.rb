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

require 'xcodeproject/xc_configuration_list'
require 'xcodeproject/build_phase_node'

module XcodeProject
	class PBXNativeTarget < Node
		attr_reader :name
		attr_reader :product_name
		attr_reader :product_reference
		attr_reader :product_type
		attr_reader :dependencies

		def initialize (root, uuid, data)
			super(root, uuid, data)

			@name = data['name']
			@product_name = data['productName']
			@product_reference = data['productReference']
			@product_type = data['productType']
			@dependencies = data['dependencies']
		end

		def sources
			sources_build_phase.files
		end

		def add_source (file)
			sources_build_phase.add_file(file)
		end

		def remove_source (file)
			sources_build_phase.remove_file(file)
		end

		def configs
			build_configurations_list.build_configurations
		end
		
		def config (name)
			build_configurations_list.build_configuration(name)
		end

		def build_configurations_list
			root.object!(data['buildConfigurationList'])
		end

		def build_phases
			data['buildPhases'].map {|uuid| root.object!(uuid) }
		end

		def sources_build_phase
			build_phases.select {|obj| obj.is_a?(PBXSourcesBuildPhase) }.first
		end

		def headers_build_phase
			build_phases.select {|obj| obj.is_a?(PBXHeadersBuildPhase) }.first
		end

		def resources_build_phase
			build_phases.select {|obj| obj.is_a?(PBXResourcesBuildPhase) }.first
		end

		def frameworks_build_phase
			build_phases.select {|obj| obj.is_a?(PBXFrameworksBuildPhase) }.first
		end

		def doctor
			build_phases.each {|phase| phase.doctor }
		end
	end
end
