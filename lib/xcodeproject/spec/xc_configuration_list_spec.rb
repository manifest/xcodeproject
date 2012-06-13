require "spec_helper"

describe XCodeProject::XCConfigurationList do
	before(:each) { @data = prepare_example_project.read }
	let(:obj)     { obj = @data.target('example').build_configurations_list }

	describe "#build_configuration" do
		let(:name) { 'Release' }
		
		it "returns build configuration object" do
			obj.build_configuration(name).should be_an_instance_of(XCodeProject::XCBuildConfiguration)
		end
	end

	describe "#build_configurations" do
		it "returns an array of build configuration objects" do
			obj.build_configurations.should be_an_instance_of(Array)
		end
	end
end
