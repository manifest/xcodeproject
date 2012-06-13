require 'xcodeproject/node'
require 'pathname'

module XCodeProject
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

