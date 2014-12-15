XcodeProject
===
The Ruby API for working with Xcode project files.

[![Pledgie Badge][pledgie_img]][pledgie]

[![Build Status][travis_img]][travis]

Installation
---
`gem install xcodeproject`

Getting started
---
A simple example that displays all targets of the project will look like this:

```ruby
require 'rubygems'
require 'xcodeproject'

proj = XcodeProject::Project.new('path/to/example.xcodeproj')
proj.read.targets.each do |target|
	puts target.name
end
```

First, you must create an XcodeProject::Project object like this:

```ruby
proj = XcodeProject::Project.new('path/to/example.xcodeproj')
```

Or you can find all projects are located in the specified directory:

```ruby
projs = XcodeProject::Project.find('path/to/dir')
```

Or by specified directory pattern:

```ruby
projs = XcodeProject::Project.find('*/**')
```

After creating the project object, you can read the data from it:

```ruby
data = proj.read
p data.target('example').config('Release').build_settings
```

Or rewrite data:

```ruby
proj.change do |data|
	data.target('example').config('Release').build_settings['GCC_VERSION'] = 'com.apple.compilers.llvmgcc42'
end
```

Files, groups and directories
---
Displaying all of top-level groups:

```ruby
data.main_group.children.each do |child|
	p child.name
end
```

Displaying files of specified group:

```ruby
group = data.group('path/from/main_group')
group.files.each do |file|
	p file.name
end
```

You can get group's (or file's) group path (the path from the main group):

```ruby
group.group_path
```

Directories are groups that are explicitly represented in the file system. For them, you can also get a file path:

```ruby
group.total_path
```

You can add a group to project by specifying the path from the main group:

```ruby
data.add_group('path/from/main_group')
```

Or from the current group:
	
```ruby
group.add_group('path/from/current_group')
```

To add a directory to the project, you must specify the file path:

```ruby
data.add_dir('group_path/to/parent', '/file_path/to/dir')
group.add_dir('/file_path/to/dir')
```

Adding files are same:

```ruby
data.add_file('group_path/to/parent', '/file_path/to/file')
group.add_file('/file_path/to/file')
```

You can also remove files, groups and directories from the project:

```ruby
data.remove_file('path/from/main_group')
data.remove_group('path/from/main_group')

group.remove_file('path/from/current_group')
group.remove_group('path/from/current_group')
```

Targets
---
Getting the target object is simple:

```ruby
target = data.target('example')
```

After adding a file to the project, you can add it to target's build phase:

```ruby
file = main_group.add_file('/file_path/to/file')
target.add_source(file)
```

Or remove from target's build phase:

```ruby
target.remove_source(file)
```

Building the project
---
XcodeProject uses Rake and XcodeBuilder for building projects.

You need to create a `rakefile`, a simple look like this:

```ruby
require 'rubygems'
require 'xcodeproject'

proj = XcodeProject::Project.new('path/to/example.xcodeproj')
XcodeProject::Tasks::BuildTask.new(proj)
```

You will now have access to a variety of tasks such as clean and build. A full list of tasks can be viewed by running `rake -T`:

```sh
$ rake -T
rake example:archive            # Creates an archive build of the specified target(s).
rake example:build              # Builds the specified target(s).
rake example:clean              # Cleans the build using the same build settings.
rake example:cleanbuild         # Builds the specified target(s) from a clean slate.
```

Configuring your tasks:

```ruby
XcodeProject::Tasks::BuildTask.new(proj) do |t|
	t.target = "libexample"
	t.configuration = "Release"
end
```

You can find out more about XcodeBuilder [here][xcodebuilder].

License
---
XcodeProject is provided under the terms of the [the MIT license][license]

[xcodebuilder]:https://github.com/lukeredpath/xcodebuild-rb
[license]:http://www.opensource.org/licenses/MIT
[pledgie]:http://pledgie.com/campaigns/17599
[pledgie_img]:http://www.pledgie.com/campaigns/17599.png?skin_name=chrome
[travis]:http://travis-ci.org/manifest/xcodeproject
[travis_img]:https://secure.travis-ci.org/manifest/xcodeproject.png
