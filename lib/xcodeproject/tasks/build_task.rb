require 'xcodebuild'

module XcodeProject
	module Tasks
		class BuildTask < XcodeBuild::Tasks::BuildTask
			def initialize (project, &block)
				super(project.name, &block)

				@formatter ||= XcodeBuild::Formatters::ProgressFormatter.new
				@project_name = project.bundle_path.basename.to_s
				@invoke_from_within = project.bundle_path.dirname
			end
		end
	end
end

