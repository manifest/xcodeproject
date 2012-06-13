require "spec_helper"

describe XCodeProject::PBXBuildFile do
	let(:root)         { prepare_example_project.read.send(:root) }
	let(:obj_file_ref) { root.project.main_group.file_ref("group1a/file2c.m") }
	let(:obj)          { root.project.target('example').sources_build_phase.send(:build_file, obj_file_ref.uuid) }

	describe "#file_ref" do
		it "returns the object" do
			obj.file_ref.should be_an_instance_of(XCodeProject::PBXFileReference)
		end
	end

	describe "#remove!" do
		it "removes the current build file" do
			obj.remove!
			root.project.target('example').sources_build_phase.send(:build_file, obj_file_ref.uuid).should be_nil
		end
		it "removes the current build file from all targets" do
			root.project.targets.each do |target|
				target.sources.map {|obj| obj.uuid }.should_not include(obj.uuid)
			end
		end
	end
end
