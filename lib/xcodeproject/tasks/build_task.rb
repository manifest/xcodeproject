#--
# The MIT License
#
# Copyright (c) 2012-2014 Andrei Nesterov <ae.nesterov@gmail.com>
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

