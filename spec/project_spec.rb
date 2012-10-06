require "spec_helper"

describe XcodeProject::Project do
	let(:proj) { prepare_example_project }

	describe "#new" do
		context "if the project file exists" do
			it "constructs an project object" do
				XcodeProject::Project.new(example_project_bundle_path).should be_an_instance_of(XcodeProject::Project)
			end
		end

		context "if the project file doesn't exist" do
			let(:proj_ne) { "#{example_empty_sandbox_path}/ghost.xcodeproj" }
			it "trows the exception" do
				lambda { XcodeProject::Project.new(proj_ne) }.should raise_exception(XcodeProject::FilePathError)
			end
		end
	end

	describe "#file_path" do
		it "returns the project's file path" do
			proj.file_path.should eql(example_project_file_path)
		end
	end

	describe "#bundle_path" do
		it "returns the project's bundle path" do
			proj.bundle_path.should eql(example_project_bundle_path)
		end
	end

	describe "#find" do
		context "if a specified directory contains project files" do
			it "returns an array of project objects" do
				projs = XcodeProject::Project.find(example_project_bundle_path)
				projs.size.should eql(1)
				projs.first.bundle_path.should eql(proj.bundle_path)
			end
		end
		
		context "if a specified directory pattern contains project files" do
			it "returns an array of project objects" do
				projs = XcodeProject::Project.find("#{example_sandbox_path}/*")
				projs.size.should eql(1)
				projs.first.bundle_path.should eql(proj.bundle_path)
			end
		end

		context "if a specified directory doesn't contain project files" do
			it "returns an empty array" do
				projs = XcodeProject::Project.find(example_empty_sandbox_path)
				projs.size.should eql(0)
			end
		end
	end

	describe "#read" do
		it "returns the data object" do
			proj.read.should be_an_instance_of(XcodeProject::Data)
		end

		it "reads the project file" do
			mock.proxy(proj).file_path
			proj.read
		end
	end

	describe "#write" do
		it "writes the project file" do
			data = proj.read

			mock.proxy(proj).file_path
			proj.write(data)
		end
	end

	describe "#change" do
		it "reads the file file and then writes it" do
			proj_mock = mock.proxy(proj)
			proj_mock.read
			proj_mock.write(is_a(XcodeProject::Data))
			proj.change {|data| }
		end
	end

	describe "#build_settings" do
		it "represents the build settings as hash" do
			proj.build_settings['TARGET_NAME'].should eql('example')
		end
	end
end

