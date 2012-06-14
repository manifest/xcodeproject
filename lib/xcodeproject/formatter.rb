module XcodeProject
	class Formatter
		def initialize
			@counter = 0
		end

		def inc
			@counter += 1
		end

		def dec
			@counter -= 1
		end

		def t1
			"\n" + "\t" * @counter
		end

		def t2
			"\n" + "\t" * (@counter + 1)
		end
	end
end
