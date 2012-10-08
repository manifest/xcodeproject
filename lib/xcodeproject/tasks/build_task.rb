require 'xcodebuild'

module XcodeProject
	module Tasks
		class BuildTask < XcodeBuild::Tasks::BuildTask
			attr_accessor :build_to
			attr_accessor :build_tmp_to

			def initialize (project, namespace = nil, &block)
				namespace ||= project.name
				super(namespace, &block)

				@project_name       = project.bundle_path.basename.to_s
				@invoke_from_within = project.bundle_path.dirname

				unless @build_to.nil?
					@build_tmp_to ||= Pathname.new(@build_to).join('.tmp')

					add_build_setting('CONFIGURATION_BUILD_DIR', @build_to)
					add_build_setting('CONFIGURATION_TEMP_DIR',  @build_tmp_to)
					add_build_setting('SYMROOT', @build_tmp_to)
				end

				bs = build_settings
				@configuration ||= bs['CONFIGURATION']
				@target        ||= bs['TARGET_NAME']
				@build_to      ||= bs['BUILT_PRODUCTS_DIR']
				@build_tmp_to  ||= bs['TARGET_TEMP_DIR']
			end

		protected

#			def build_opts_without_project
#				build_opts.gsub(/-project\s+\w+/, '')
#			end
		end
	end
end

