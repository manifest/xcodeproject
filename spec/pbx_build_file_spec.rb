require_relative 'spec_helper'

describe XcodeProject::PBXBuildFile do
  let(:root)         { prepare_example_project.read.send(:root) }
  let(:obj_file_ref) { root.project.main_group.file_ref('group1a/file2c.m') }
  let(:obj)          { root.project.target('example').sources_build_phase.send(:build_file, obj_file_ref.uuid) }

  describe '#file_ref' do
    it 'returns the object' do
      expect(obj.file_ref).to be_a(XcodeProject::PBXFileReference)
    end
  end

  describe '#remove!' do
    it 'removes the current build file' do
      obj.remove!
      expect(root.project.target('example').sources_build_phase.send(:build_file, obj_file_ref.uuid)).to be_nil
    end

    it 'removes the current build file from all targets' do
      root.project.targets.each do |target|
        expect(target.sources.map(&:uuid)).not_to include(obj.uuid)
      end
    end
  end
end
