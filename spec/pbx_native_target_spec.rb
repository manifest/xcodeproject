require_relative 'spec_helper'

describe XcodeProject::PBXNativeTarget do
  let(:obj) { @data.target('example') }

  before(:each) do
    @data = prepare_example_project.read
  end

  describe '#sources' do
    it '=> PBXSourcesBuildPhase#files' do
      files = mock
      mock(obj).sources_build_phase.mock!.files do files end
      expect(obj.sources).to eql(files)
    end
  end

  describe '#add_source' do
    it '=> PBXSourcesBuildPhase#add_file' do
      file = mock
      mock(obj).sources_build_phase.mock!.add_file(file)
      obj.add_source(file)
    end
  end

  describe '#remove_source' do
    it '=> PBXSourcesBuildPhase#remove_file' do
      file = mock
      mock(obj).sources_build_phase.mock!.remove_file(file)
      obj.remove_source(file)
    end
  end

  describe '#build_configurations_list' do
    it 'returns the build configuration list object' do
      expect(obj.build_configurations_list).to be_a(XcodeProject::XCConfigurationList)
    end
  end

  describe '#configs' do
    it '=> XCConfigurationList#build_configurations' do
      res = mock
      mock(obj).build_configurations_list.mock!.build_configurations do res end
      expect(obj.configs).to eql(res)
    end
  end

  describe '#config' do
    it '=> XCConfigurationList#build_configuration' do
      name = mock
      res = mock
      mock(obj).build_configurations_list.mock!.build_configuration(name) do res end
      expect(obj.config(name)).to eql(res)
    end
  end

  describe '#build_phases' do
    it 'returns the array of build phase objects' do
      expect(obj.build_phases).to be_a(Array)
    end
  end
end
