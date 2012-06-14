require 'xcodebuild'

module XcodeProject
	class Builder < XcodeBuild::Tasks::BuildTask
		def initialize (&block)
			super(block)
		end

		def build
			run('build')
		end

		def clean
			run('clean')
		end

		def archive
			run('archive')
		end
	end
end
