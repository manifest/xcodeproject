require "spec_helper"
require "xcodebuild"

describe XcodeProject::Util::PListAccessor do
	before(:each) do
		@proj = prepare_example_project
		@data = @proj.read
	end

	let(:build_settings) { XcodeBuild.build_settings("-project #{@proj.bundle_path}") }
	let(:obj)            { @data.target('example').config('Release').plist }

	describe "#read_property" do
		let(:key) { 'CFBundleIdentifier' }

		context "with key argument only" do
			let(:value) { 'org.yanot.${PRODUCT_NAME:rfc1034identifier}' }
			it "reads a property by key from plist file" do
				obj.read_property(key).should eql(value)
			end
		end

		context "with key and hash arguments" do
			let(:value) { 'org.yanot.example' }
			it "reads a property by key from plist file and replace placeholders" do
				obj.read_property(key, build_settings).should eql(value)
			end
		end
	end

	describe "#write_property" do
		let(:key)   { 'CFBundleShortVersionString' }
		let(:value) { '1.1' }

		it "writes value by key to plist file" do
			obj.write_property(key, value)
			obj.read_property(key).should eql(value)
		end
	end

	describe "#replace_placeholders" do
		let(:key)   { 'CFBundleIdentifier' }
		let(:value) { 'org.yanot.example' }
		
		it "replaces placeholders in the plist property" do
			text = obj.read_property(key)
			obj.replace_placeholders(text, build_settings).should eql(value)
		end
	end
end

