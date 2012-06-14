#--
# Copyright 2012 by Andrey Nesterov (ae.nesterov@gmail.com)
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

require 'xcodeproject/root_node'

module XcodeProject
	class Data
		def initialize (data, wd)
			@root = RootNode.new(data, wd)
		end

		def project
			@root.project
		end

		def targets
			project.targets
		end

		def target (name)
			project.target(name)
		end

		def main_group
			project.main_group
		end

		def group (gpath)
			main_group.group(gpath)
		end

		def add_group (gpath)
			main_group.add_group(gpath)
		end

		def add_dir(parent_gpath, path)
			main_group.add_group(parent_gpath).add_dir(path)
		end

		def remove_group (gpath)
			main_group.remove_group(gpath)
		end
		
		def file (gpath)
			main_group.file(gpath)
		end

		def add_file (parent_gpath, path)
			main_group.add_group(parent_gpath).add_file(path)
		end

		def remove_file (gpath)
			main_group.remove_file(gpath)
		end

		def doctor
			targets.each {|target| target.doctor }
		end

		def to_plist (fmtr = Formatter.new)
			@root.to_plist
		end

	private
		attr_accessor :root

	end
end
