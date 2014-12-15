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

require 'xcodeproject/node'
require 'pathname'

module XcodeProject
	class FileNode < Node
		attr_reader :name
		attr_reader :path
		attr_reader :source_tree

		def initialize (root, uuid, data)
			super(root, uuid, data)

			@source_tree = data['sourceTree']
			@name ||= data['name']
			@path ||= data['path']

			@name ||= File.basename(@path) unless @path.nil?
		end

		def source_tree
			SourceTreeMap[@source_tree]
		end

		def parent
			root.select_objects do |uuid, data|
				(data['children'].include?(self.uuid) if data['isa'] == 'PBXGroup') ? true : false
			end.first
		end

		def group_path
			obj = self
			res = ''
			begin
				pn = obj.name ? obj.name : ''
				res = Pathname.new(pn).join(res)
			end while obj = obj.parent;
			res.cleanpath
		end

		def total_path
			res = ''
			case source_tree
				when :source_root
					res = path
				when :group
					pn = path.nil? ? '' : path
					res = parent.total_path.join(pn) unless parent.nil?
				else
					raise ParseError.new("No such '#{source_tree}' source tree type.")
			end
			root.absolute_path(res)
		end

	private

		SourceTreeMap = {
			'SOURCE_ROOT' => :source_root,
			'<group>'     => :group
		}

	end
end

