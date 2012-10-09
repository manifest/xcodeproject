require 'xcodebuild'

module XcodeProject
	module Tasks
		class BuildTask < XcodeBuild::Tasks::BuildTask

			def initialize (project, namespace = nil, &block)
				@project  = project
				namespace ||= project.name
				super(namespace) do |t|
					yield self if block_given?

					t.project_name       = project.bundle_path.basename.to_s
					t.invoke_from_within = project.bundle_path.dirname
				end
			end
		
		end
	end
end

