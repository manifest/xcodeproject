#
#	Example proj file hierarhy
#
# main
# \--group1a
#    |--group2a
#    |--dir2c
#    |   \--dir3a
#    |      \--dir4a
#    |         |--file5a-a.m
#    |         |--file5a-a.h
#    |         |--file5a-r.m
#    |         \--file5a-r.h
#    |
#    |--file2c.m
#    \--file2c.h

require 'xcodeproject/project'
require 'xcodeproject/exceptions'
require 'rr' 

RSpec.configure do |config|
  config.mock_with :rr
end 

def prepare_sandbox
	%x{ mkdir -p #{example_sandbox_path} } unless File.exist?(example_sandbox_path)
end

def prepare_example_project
	prepare_sandbox

	proj_source_dir = "#{File.dirname(__FILE__)}/../resources/example"
	%x{ rm -vr #{example_project_dir} }
	%x{ cp -vr #{proj_source_dir} #{example_sandbox_path} }

	XcodeProject::Project.new(example_project_bundle_path)
end

def example_sandbox_path;        Pathname.new('/tmp/example_sandbox') end
def example_empty_sandbox_path;  Pathname.new('/tmp/example_sandbox_empty') end
def example_project_dir;         example_sandbox_path.join('example') end
def example_project_bundle_path; example_project_dir.join('example.xcodeproj') end
def example_project_file_path;   example_project_bundle_path.join('project.pbxproj') end

