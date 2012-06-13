require 'uuid'

module XCodeProject
	class UUIDGenerator
		def initialize
			@generator = UUID.new
		end

		def generate
			@generator.generate(:compact).slice(0..23).upcase
		end
	end
end
