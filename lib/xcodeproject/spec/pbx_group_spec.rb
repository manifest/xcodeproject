require "spec_helper"

describe XcodeProject::PBXGroup do
	let(:root) { prepare_example_project.read.send(:root) }
	let(:obj)  { root.project.main_group.group('group1a') }

	describe "#children" do
		context "if children exists" do
			it "returns an array of children objects" do
				obj.children.should be_an_instance_of(Array)
				obj.children.size.should > 0
			end
		end
		context "if children doesn't exist" do
			let(:empty_group_obj) { root.project.main_group.group("group1a/group2a") }

			it "returns an empty array" do
				empty_group_obj.children.should be_an_instance_of(Array)
				empty_group_obj.children.size.should eql(0)
			end
		end
	end

	describe "#files" do
		context "if children exists" do
			it "Returns an array of only those children who are files" do
				chs = obj.files
				chs.should be_an_instance_of(Array)
				chs.size.should > 0
				chs.each do |child|
					child.should be_an_instance_of(XcodeProject::PBXFileReference)
				end
			end
		end
		context "if children doesn't exist" do
			let(:obj) { root.project.main_group.group("group1a/dir2c") }

			it "returns an empty array" do
				chs = obj.files
				chs.should be_an_instance_of(Array)
				chs.size.should eql(0)
			end
		end
	end

	describe "#groups" do
		context "if children exists" do
			it "Returns an array of only those children who are group" do
				chs = obj.groups
				chs.should be_an_instance_of(Array)
				chs.size.should > 0
				chs.each do |child|
					child.should be_an_instance_of(XcodeProject::PBXGroup)
				end
			end
		end
		context "if children doesn't exist" do
			let(:obj) { root.project.main_group.group("group1a/dir2c/dir3a/dir4a") }

			it "returns an empty array" do
				chs = obj.groups
				chs.should be_an_instance_of(Array)
				chs.size.should eql(0)
			end
		end
	end

	describe "#child" do
		context "if passed '.'" do
			it "returns the self" do
				obj.child('.').uuid.should eql(obj.uuid)
			end
		end
		context "if passed '..'" do
			it "returns the parent" do
				obj.child('..').uuid.should eql(obj.parent.uuid)
			end
		end
		context "if passed a child name" do
			it "returns the child object" do
				[
					'group2a',
					'dir2c',
					'file2c.m'
				].each do |name|
					obj.child(name).should_not be_nil
				end
			end
		end
		context "if passed the group path" do
			it "returns the child object" do
				[
					'dir2c/dir3a',
					'dir2c/dir3a/dir4a/file5a-a.m',
					'dir2c/dir3a/dir4a/file5a-r.m',
					'dir2c/../dir2c/dir3a/./dir4a/file5a-r.m'
				].each do |gpath|
					obj.child(gpath).should_not be_nil
				end
			end
		end
		context "if child doesn't exist" do
			it "returns nil" do
				[
					'group2a_ghost',
					'group2a_ghost/file3c_ghost.m',
					'dir2c/file3c_ghost.m'
				].each do |gpath|
					obj.child(gpath).should be_nil
				end
			end
		end
	end

	describe "#group?" do
		let(:dir_obj) { obj.child('dir2c') }

		context "if the current group is abstract" do
			it "returns true" do
				obj.group?.should eql(true)
			end
		end
		context "if the current group is directory" do
			it "returns false" do
				dir_obj.group?.should eql(false)
			end
		end
	end

	describe "#dir?" do
		let(:dir_obj) { obj.child('dir2c') }

		context "if the current group is directory" do
			it "returns true" do
				dir_obj.dir?.should eql(true)
			end
		end
		context "if the current group is abstract" do
			it "returns false" do
				obj.dir?.should eql(false)
			end
		end
	end

	describe "#group" do
		context "if the group exists" do
			it "returns the object" do
				obj.group('group2a').should be_an_instance_of(XcodeProject::PBXGroup)
			end
		end
		context "if the group doesn't exist" do
			it "returns nil" do
				obj.group('group2a_ghost').should be_nil
			end
		end
	end

	describe "#file_ref" do
		context "if the file reference exists" do
			it "returns the object" do
				obj.file_ref('file2c.m').should be_an_instance_of(XcodeProject::PBXFileReference)
			end
		end
		context "if the file reference doesn't exist" do
			it "returns nil" do
				obj.file_ref('file2c_ghost.m').should be_nil
			end
		end
	end

	describe "#add_file_ref" do
		context "if passed the relative path" do
			it "adds the file reference, returns the object" do
				obj.send(:add_file_ref, 'dir1b/file2b.m').should be_an_instance_of(XcodeProject::PBXFileReference)
			end
		end
		context "if passed the absolute path" do
			it "adds the file reference, returns the object" do
				obj.send(:add_file_ref, "#{example_project_dir}/dir1b/file2b.m").should be_an_instance_of(XcodeProject::PBXFileReference)
			end
		end
		context "if file reference already exists" do
			it "new object has same uuid as existing" do
				uuid = obj.file_ref('file2c.m').uuid
				obj.send(:add_file_ref, 'dir1c/file2c.m').uuid.should eql(uuid)
			end
		end
		context "if file doesn't exit" do
			it "raise an exception " do
				lambda { obj.send(:add_file_ref, "file2c_ghost.m") }.should raise_exception(XcodeProject::FilePathError)
			end
		end
	end

	describe "#add_group" do
		it "adds the group, returns the object" do
			group_obj = obj.add_group("group2a_ghost")
			group_obj.should be_an_instance_of(XcodeProject::PBXGroup)
			group_obj.group?.should eql(true)
		end
	end

	describe "#add_dir" do
		it "adds the group, returns the object" do
			group_obj = obj.add_dir("dir1c")
			group_obj.should be_an_instance_of(XcodeProject::PBXGroup)
			group_obj.dir?.should eql(true)
		end
		it "adds all dir's children" do
			obj.add_dir('dir1c')
			[
				obj.group('dir1c'),
				obj.group('dir1c/dir2c'),
				obj.file('dir1c/file2c.m')
			].each {|obj| obj.should_not be_nil }
		end
		context "if dir doesn't exit" do
			it "raise an exception " do
				lambda { obj.add_dir("dir2c_ghost") }.should raise_exception(XcodeProject::FilePathError)
			end
		end
	end

	describe "#create_group" do
		context "if passed a group name" do
			it "creates and returns the group object" do
				obj.create_group('group2a_ghost').should be_an_instance_of(XcodeProject::PBXGroup)
			end
		end
		context "if passed a group path" do
			it "creates missed groups and returns the last group object" do
				[
					'group2a/group3a_ghost',
					'group2a_ghost/group3a_ghost',
					'group2a_ghost/../create_group2a_ghost/./group3a_ghost'
				].each do |gpath|
					obj.create_group(gpath).should be_an_instance_of(XcodeProject::PBXGroup)
				end
			end
		end
		context "if group already exists" do
			it "new object has same uuid as existing" do
				uuid = obj.child('group2a').uuid
				obj.create_group('group2a').uuid.should eql(uuid)
			end
		end
	end

	describe "#remove_group" do
		context "if the group exists" do
			it "removes the object" do
				obj.remove_group('group2a')
				obj.group('group2a').should be_nil
			end
		end
		context "if the group doesn't exist" do
			it "returns nil" do
				obj.remove_group('group2a_ghost').should be_nil
			end
		end
	end

	describe "#remove!" do
		it "removes the current group" do
			obj.remove!
			root.project.main_group.group('group1a').should be_nil
		end
	end

	describe "#absolute_path" do
		let(:dir_obj) { root.project.main_group.group('group1a/dir2c/dir3a') }

		it "makes the absolute path" do
			[
				"dir4a/file5a-a.m",
				"#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-a.m"
			].map {|path| dir_obj.absolute_path(path) }.should eql([
				Pathname.new("#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-a.m"),
				Pathname.new("#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-a.m")
			]) 
		end
	end

	describe "#relative_path" do
		let(:dir_obj) { root.project.main_group.group('group1a/dir2c/dir3a') }

		it "makes the relative path" do
			[
				"dir4a/file5a-a.m",
				"#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-a.m"
			].map {|path| dir_obj.relative_path(path) }.should eql([
				Pathname.new("dir4a/file5a-a.m"),
				Pathname.new("dir4a/file5a-a.m")
			]) 
		end
	end

	it_behaves_like "a file node" do
		let(:main_group) {
			root.project.main_group
		}
		let(:file_nodes_gpaths) {[
			"group1a/dir2c/dir3a/dir4a",
			"group1a/dir2c/dir3a",
			"group1a/dir2c",
			"group1a/group2a",
			"group1a"
		]}
		let(:file_nodes_total_paths) {[
			"#{example_project_dir}/dir1a/dir2a/dir3a/dir4a",
			"#{example_project_dir}/dir1a/dir2a/dir3a",
			"#{example_project_dir}/dir1c/dir2c",
			example_project_dir,
			example_project_dir
		]}
	end
end

