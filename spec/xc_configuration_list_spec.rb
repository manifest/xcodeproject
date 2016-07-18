require_relative 'spec_helper'

describe XcodeProject::XCConfigurationList do
  let(:obj) { @data.target('example').build_configurations_list }

  before(:each) do
    @data = prepare_example_project.read
  end

  describe '#build_configuration' do
    let(:name) { 'Release' }

    it 'returns build configuration object' do
      expect(obj.build_configuration(name)).to be_a(XcodeProject::XCBuildConfiguration)
    end
  end

  describe '#build_configurations' do
    it 'returns an array of build configuration objects' do
      expect(obj.build_configurations).to be_a(Array)
    end
  end
end
