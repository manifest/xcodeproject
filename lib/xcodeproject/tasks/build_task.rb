require 'xcodebuild'

module XcodeProject
	module Tasks
		class BuildTask < XcodeBuild::Tasks::BuildTask
			attr_accessor :with_build_opts

			def initialize (project, namespace = nil, &block)
				namespace ||= project.name
				super(namespace, &block)

				@with_build_opts  ||= []
				@formatter        ||= XcodeBuild::Formatters::ProgressFormatter.new

				@project_name       = project.bundle_path.basename.to_s
				@invoke_from_within = project.bundle_path.dirname
			end

		private

			def build_opts
				super + with_build_opts
			end
		end
	end
end

