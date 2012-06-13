module XCodeProject
	class Node
		attr_reader :uuid
		attr_reader :isa

		def initialize (root, uuid, data)
			@root, @uuid, @data = root, uuid, data
			@isa = data['isa']
		end
		
		protected
			attr_accessor :root
			attr_accessor :data
	end
end
