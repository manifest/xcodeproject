require 'xcodeproject/node'
require 'xcodeproject/util/plist_accessor'
require 'rexml/document'

module XcodeProject
	class XCBuildConfiguration < Node
		attr_reader :name
		attr_reader :plist
		attr_accessor :build_settings

		def initialize (root, uuid, data)
			super(root, uuid, data)

			@name = data['name']
			@build_settings = data['buildSettings']
			
			@plist = PListAccessor.new(@build_settings['INFOPLIST_FILE'])
		end

		def version (type = :major)
			major = @plist.read_property('CFBundleShortVersionString')
			minor = @plist.read_property('CFBundleVersion')

			case type
				when :major ; major
				when :minor ; minor
				when :both  ; major + '.' + minor
				else raise ArgumentError.new('Wrong argument type, expected :major, :minor or :both.')
			end
		end

		def change_version (value, type = :major)
			case type
				when :major ; @plist.write_property('CFBundleShortVersionString', value)
				when :minor ; @plist.write_property('CFBundleVersion', value)
				else raise ArgumentError.new('Wrong argument type, expected :major or :minor.')
			end
		end

		def increment_version (type = :major)
			cv = version(type)
			nv = cv.nil? ? '0' : cv.next

			change_version(nv, type)
		end

	end
end
