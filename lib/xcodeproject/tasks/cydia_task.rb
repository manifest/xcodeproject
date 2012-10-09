require 'xcodeproject/tasks/build_task'
require 'xcodeproject/tasks/debian_package_task'

module XcodeProject
	module Tasks
		class CydiaTask < BuildTask
			include DebianPackageTask
		end
	end
end
