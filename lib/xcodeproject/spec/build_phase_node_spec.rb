require "spec_helper"

describe XCodeProject::BuildPhaseNode do
	let(:root)       { prepare_example_project.read.send(:root) }
	let(:file_ref)   { root.project.main_group.file_ref('group1a/file2c.m') }
	let(:build_file) { root.project.target('example').sources_build_phase.send(:build_file, file_ref.uuid) }
	let(:obj)        { obj = root.project.target('example').sources_build_phase }

	describe "#files" do
		it "returns an array of files" do
			obj.files.should be_an_instance_of(Array)
			obj.files.each {|obj| obj.should be_an_instance_of(XCodeProject::PBXFileReference) }
		end
	end
	
	describe "#add_file" do
		context "if passed an object of the PBXFileReference type" do
			it "=> add_build_file" do
				mock(obj).add_build_file(file_ref.uuid)
				obj.add_file(file_ref)
			end
		end
		context "if passed an object of the PBXBuildFile type" do
			it "=> add_build_file_uuid" do
				mock(obj).add_build_file_uuid(build_file.uuid)
				obj.add_file(build_file)
			end
		end
		context "if passed the object of unsupported type" do
			it "raise an exception" do
				lambda { obj.add_file(stub) }.should raise_exception(ArgumentError)
			end
		end
	end
	
	describe "#remove_file" do
		context "if passed an object of the PBXFileReference type" do
			it "=> remove_build_file_uuid" do
				mock(obj).remove_build_file_uuid(root.project.target('example').sources_build_phase.send(:build_file, file_ref.uuid).uuid)
				obj.remove_file(file_ref)
			end
		end
		context "if passed an object of the PBXBuildFile type" do
			it "=> remove_build_file_uuid" do
				mock(obj).remove_build_file_uuid(build_file.uuid)
				obj.remove_file(build_file)
			end
		end
		context "if passed the object of unsupported type" do
			it "raise an exception" do
				lambda { obj.remove_file(stub) }.should raise_exception(ArgumentError)
			end
		end
	end

	describe "#build_files" do
		it "returns an array of files" do
			obj.send(:build_files).should be_an_instance_of(Array)
			obj.send(:build_files).each {|obj| obj.should be_an_instance_of(XCodeProject::PBXBuildFile) }
		end
	end

	describe "#build_file" do
		it "returns the object" do
			obj.send(:build_file, file_ref.uuid).should be_an_instance_of(XCodeProject::PBXBuildFile)
		end
	end

	describe "#add_build_file" do
		it "adds the build file, returns the object" do
			obj.send(:add_build_file, file_ref.uuid).should be_an_instance_of(XCodeProject::PBXBuildFile)
		end
	end

	describe "#remove_build_file" do
		it "=> remove_build_file_uuid" do
			mock(obj).remove_build_file_uuid(build_file.uuid)
			obj.send(:remove_build_file, file_ref.uuid)
		end
	end

	describe "#add_build_file_uuid" do
		it "adds the build file uuid to the build list" do
			obj.send(:add_build_file_uuid, build_file.uuid)
			obj.send(:build_files).map {|obj| obj.uuid }.should include(build_file.uuid)
		end
	end

	describe "#remove_build_file_uuid" do
		it "removes the build file uuid from the build list" do
			obj.send(:remove_build_file_uuid, build_file.uuid)
			obj.send(:build_files).map {|obj| obj.uuid }.should_not include(build_file.uuid)
		end
	end
end
