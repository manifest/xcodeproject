require "spec_helper"

describe XcodeProject::FileNode do
	let(:data_name)      { Hash['name', 'file.name'] }
	let(:data_path)      { Hash['path', 'path/to/file.name'] }
	let(:data_path_name) { data_path.merge!(data_name) }
	let(:data_empty)     { Hash.new }

	describe "#name" do
		context "if the name is initialized " do
			it "returns the name as is" do
				[data_name, data_path_name].each do |data|
					XcodeProject::FileNode.new(stub, stub, data).name.should eql(data['name'])
				end
			end
		end
		context "if the name isn't initialized" do
			context "and the path is initialized " do
				it "returns the name as basename of the path" do
					XcodeProject::FileNode.new(stub, stub, data_path).name.should eql(File.basename(data_path['path']))
				end
			end
			context "and the path isn't initialized" do
				it "returns nil" do
					XcodeProject::FileNode.new(stub, stub, data_empty).name.should be_nil
				end
			end
		end
	end
	
	describe "#path" do
		context "if the path is initialized " do
			it "returns the path as is" do
				[data_path, data_path_name].each do |data|
					XcodeProject::FileNode.new(stub, stub, data_path).path.should eql(data['path'])
				end
			end
		end
		context "if the path isn't initialized" do
			it "returns nil" do
				XcodeProject::FileNode.new(stub, stub, data_empty).path.should be_nil
			end
		end
	end
		
	describe "#parent" do
		let(:root) { prepare_example_project.read.send(:root) }

		context "if the current object is the main group" do
			it "returns nil" do
				root.project.main_group.parent.should be_nil
			end
		end
	end

	shared_examples_for "a file node" do
		describe "#parent" do
			context "if the object is nested file node" do
				it "returns the parent object" do
					file_nodes_gpaths do |gpath| 
						main_group.child(gpath).parent.should be_an_instance_of(XcodeProject::PBXGroup)
					end
				end
			end
		end
		
		describe "#group_path" do
			it "returns the abstract path from project main group" do
				file_nodes_gpaths.map do |gpath| 
					main_group.child(gpath).group_path
				end.should eql(file_nodes_gpaths.map {|gpath| Pathname.new(gpath) })
			end
		end
		
		describe "#total_path" do
			it "returns the absolute file path" do
				file_nodes_gpaths.map do |gpath| 
					main_group.child(gpath).total_path
				end.should eql(file_nodes_total_paths.map {|gpath| Pathname.new(gpath) })
			end
		end
	end
end
