#--
# Copyright 2012 by Andrei Nesterov (ae.nesterov@gmail.com)
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

require 'xcodeproject/node'
require 'xcodeproject/pbx_build_file'

module XcodeProject
	class BuildPhaseNode < Node
		def initialize (root, uuid, data)
			super(root, uuid, data)
			@files = data['files']
		end

		def files
			build_files.map {|obj| obj.file_ref }
		end

		def add_file (file_obj)
			case file_obj
				when PBXFileReference
					add_build_file(file_obj.uuid)
				when PBXBuildFile
					add_build_file_uuid(file_obj.uuid)
				else 
					raise ArgumentError.new("Wrong argument type, expected the PBXFileReference or PBXBuildFile.")
			end
		end

		def remove_file (file_obj)
			case file_obj
				when PBXFileReference
					remove_build_file(file_obj.uuid)
				when PBXBuildFile
					remove_build_file_uuid(file_obj.uuid)
				else 
					raise ArgumentError.new("Wrong argument type, expected the PBXFileReference or PBXBuildFile.")
			end
		end

		def doctor
			@files.each do |uuid|
				obj = root.object(uuid)
				if obj.nil?
					remove_build_file_uuid(uuid)
					puts "removed #{uuid}"
				end
			end
		end

	private

		def build_files
			@files.map {|uuid| root.object!(uuid) }
		end

		def build_file (file_ref_uuid)
			build_files.select {|obj| obj.file_ref.uuid == file_ref_uuid }.first
		end

		def add_build_file (file_ref_uuid)
			obj = build_file(file_ref_uuid)
			if obj.nil?
				obj = PBXBuildFile.add(root, file_ref_uuid)
				add_build_file_uuid(obj.uuid)
			end
			obj
		end

		def remove_build_file (file_ref_uuid)
			obj = build_file(file_ref_uuid)
			remove_build_file_uuid(obj.uuid) unless obj.nil?
		end

		def add_build_file_uuid (build_file_uuid)
			@files << build_file_uuid unless @files.include?(build_file_uuid)
		end

		def remove_build_file_uuid (build_file_uuid)
			@files.delete(build_file_uuid)
		end
	end

	class PBXSourcesBuildPhase < BuildPhaseNode; end
	class PBXHeadersBuildPhase < BuildPhaseNode; end
	class PBXResourcesBuildPhase < BuildPhaseNode; end
	class PBXFrameworksBuildPhase < BuildPhaseNode; end
	class PBXAppleScriptBuildPhase < BuildPhaseNode; end
	class PBXShellScriptBuildPhase < BuildPhaseNode; end
	class PBXCopyFilesBuildPhase < BuildPhaseNode; end
end
