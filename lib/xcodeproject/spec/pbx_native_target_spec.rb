require "spec_helper"

describe XcodeProject::PBXNativeTarget do
	before(:each) { @data = prepare_example_project.read }
	let(:obj)     { obj = @data.target('example') }

	describe "#sources" do
		it "=> PBXSourcesBuildPhase#files" do
			files = mock
			mock(obj).sources_build_phase.mock!.files { files }
			obj.sources.should eql(files)
		end
	end

	describe "#add_source" do
		it "=> PBXSourcesBuildPhase#add_file" do
			file = mock
			mock(obj).sources_build_phase.mock!.add_file(file)
			obj.add_source(file)
		end
	end

	describe "#remove_source" do
		it "=> PBXSourcesBuildPhase#remove_file" do
			file = mock
			mock(obj).sources_build_phase.mock!.remove_file(file)
			obj.remove_source(file)
		end
	end

	describe "#build_configurations_list" do
		it "returns the build configuration list object" do
			obj.build_configurations_list.should be_an_instance_of(XcodeProject::XCConfigurationList)
		end
	end

	describe "#configs" do
		it "=> XCConfigurationList#build_configurations" do
			res = mock
			mock(obj).build_configurations_list.mock!.build_configurations { res }
			obj.configs.should eql(res)
		end
	end

	describe "#config" do
		it "=> XCConfigurationList#build_configuration" do
			name, res = mock, mock
			mock(obj).build_configurations_list.mock!.build_configuration(name) { res }
			obj.config(name).should eql(res)
		end
	end

	describe "#build_phases" do
		it "returns the array of build phase objects" do
			obj.build_phases.should be_an_instance_of(Array)
		end
	end
end
