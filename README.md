XCodeProject
===
Ruby API for working with Xcode project files

Installation
---
`gem install xcodeproject`

Getting started
---
A simple example that displays all targets of the project will look like this:

	require 'rubygems'
	require 'xcodeproject'

	proj = XcodeProject::Project.new('path/to/example.xcodeproj')
	proj.read.targets.each do |target|
		puts target.name
	end

First, you must create an XcodeProject::Project object like this:

	proj = XcodeProject::Project.new('path/to/example.xcodeproj')

Or you can find all projects are located in the specified directory:

	projs = XCodeProject::Project.find_projs('path/to/dir')

After creating the project object, you can read the data from it:

	proj = XcodeProject::Project.new('path/to/example.xcodeproj')
	data = proj.read
	p data.target('example').config('Release').build_settings

Or rewrite data:

	proj = XcodeProject::Project.new('path/to/example.xcodeproj')
	proj.change do |data|
		data.target('example').config('Release').build_settings['GCC_VERSION'] = 'com.apple.compilers.llvmgcc42'
	end

Build the project
---
XcodeProject uses XcodeBuilder for building projects

Building the project:

	proj = XcodeProject::Project.new('example/example.xcodeproj')
	proj.build

Cleaning the project:

	proj = XcodeProject::Project.new('example/example.xcodeproj')
	proj.clean

Archiving the project:

	proj = XcodeProject::Project.new('example/example.xcodeproj')
	proj.builder.scheme = 'example'
	proj.archive

You can specify options for builder:

	proj = XcodeProject::Project.new('example/example.xcodeproj')
	proj.builder.configuration = 'Debug'
	proj.builder.arch = 'armv7'
	proj.build

You can find out more about XcodeBuilder [here][xcodebuilder].

License
---
XCodeProject is provided under the terms of the [the MIT license][license]

[xcodebuilder]:https://github.com/lukeredpath/xcodebuild-rb
[license]:http://www.opensource.org/licenses/MIT

