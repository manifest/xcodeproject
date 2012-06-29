require 'xcodebuild'

module XcodeProject
	module Tasks
		class BuildTask < XcodeBuild::Tasks::BuildTask
			attr_accessor :with_build_opts
			attr_accessor :build_to

			def initialize (project, namespace = nil, &block)
				namespace ||= project.name
				super(namespace, &block)

				@project_name       = project.bundle_path.basename.to_s
				@invoke_from_within = project.bundle_path.dirname

				@formatter        ||= XcodeBuild::Formatters::ProgressFormatter.new
				@with_build_opts  ||= []
				
				unless @build_to.nil?
					build_tmp_to = Pathname.new(@build_to).join('.tmp')

					@with_build_opts << %{ CONFIGURATION_BUILD_DIR="#{@build_to}" }
					@with_build_opts << %{ CONFIGURATION_TEMP_DIR="#{build_tmp_to}" }
					@with_build_opts << %{ SYMROOT="#{build_tmp_to}" }
				end
			end

		private

			def build_opts
				super + with_build_opts
			end
		end
	end
end

