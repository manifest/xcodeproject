require "spec_helper"

describe XcodeProject::XCBuildConfiguration do
	before(:each) { @data = prepare_example_project.read }
	let(:obj)     { obj = @data.target('example').config('Release') }

	describe "#plist_path" do
		it "returns plist file path" do
			obj.send(:plist_path).should eql(example_project_dir.join('example/example-Info.plist'))
		end
	end

	describe "#version" do
		context "by default" do
			it "returns major version" do
				obj.version.should eql(obj.version(:major))
			end
		end
		context "if passed :major" do
			it "returns major version" do
				obj.version(:major).should eql('1.0')
			end
		end
		context "if passed :minor" do
			it "returns minor version" do
				obj.version(:minor).should eql('345')
			end
		end
		context "if passed :both" do
			it "returns both, major and minor versions" do
				obj.version(:both).should eql('1.0.345')
			end
		end
	end

	describe "#change_version" do
		let(:version) { '2.0' }

		context "by default" do
			it "changes major version" do
				obj.change_version(version)
				obj.version(:major).should eql(version)
			end
		end
		
		context "if passed :major" do
			it "changes major version" do
				obj.change_version(version, :major)
				obj.version(:major).should eql(version)
			end
		end

		context "if passed :minor" do
			it "changes minor version" do
				obj.change_version(version, :minor)
				obj.version(:minor).should eql(version)
			end
		end
	end

	describe "#increment_version" do
		context "by default" do
			let(:next_version) { '1.1' }

			it "increments major version" do
				obj.increment_version
				obj.version(:major).should eql(next_version)
			end
		end
		
		context "if passed :major" do
			let(:next_version) { '1.1' }

			it "increments major version" do
				obj.increment_version(:major)
				obj.version(:major).should eql(next_version)
			end
		end

		context "if passed :minor" do
			let(:next_version) { '346' }

			it "increments minor version" do
				obj.increment_version(:minor)
				obj.version(:minor).should eql(next_version)
			end
		end
	end

	describe "#read_property" do
		let(:key) { 'CFBundleShortVersionString' }
		let(:value) { '1.0' }

		it "read a property by key from plist file" do
			obj.send(:read_property, key).should eql(value)
		end
	end

	describe "#write_property" do
		let(:key)   { 'CFBundleShortVersionString' }
		let(:value) { '1.1' }

		it "write value by key to plist file" do
			obj.send(:write_property, key, value)
			obj.send(:read_property, key).should eql(value)
		end
	end
end
