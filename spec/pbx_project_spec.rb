require_relative 'spec_helper'

describe XcodeProject::PBXProject do
  let(:obj) { @data.project }

  before(:each) do
    @data = prepare_example_project.read
  end

  describe '#targets' do
    it 'returns the array of target objects' do
      targets = obj.targets
      expect(targets).to be_a(Array)
      targets.each do |obj|
        expect(obj).to be_a(XcodeProject::PBXNativeTarget)
      end
    end
  end

  describe '#target' do
    context 'if the target exists' do
      it 'returns the object' do
        expect(obj.target('example')).to be_a(XcodeProject::PBXNativeTarget)
      end
    end

    context 'if the target doesn\'t exist' do
      it 'returns nil' do
        expect(obj.target('ghost-target')).to be_nil
      end
    end
  end

  describe '#main_group' do
    it 'returns the main group object' do
      expect(obj.main_group).to be_a(XcodeProject::PBXGroup)
    end
  end
end
