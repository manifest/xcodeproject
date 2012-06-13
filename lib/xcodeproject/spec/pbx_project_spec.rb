require "spec_helper"

describe XCodeProject::PBXProject do
	before(:each) { @data = prepare_example_project.read }
	let(:obj)     { @data.project }

	describe "#targets" do
		it "returns the array of target objects" do
			targets = obj.targets
			targets.should be_an_instance_of(Array)
			targets.each {|obj| obj.should be_an_instance_of(XCodeProject::PBXNativeTarget) }
		end
	end
	
	describe "#target" do
		context "if the target exists" do
			it "returns the object" do
				obj.target('example').should be_an_instance_of(XCodeProject::PBXNativeTarget)
			end
		end
		context "if the target doesn't exist" do
			it "returns nil" do
				obj.target('ghost-target').should be_nil
			end
		end
	end

	describe "#main_group" do
		it "returns the main group object" do
			obj.main_group.should be_an_instance_of(XCodeProject::PBXGroup)
		end
	end
end

