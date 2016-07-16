require_relative 'spec_helper'

describe XcodeProject::BuildPhaseNode do
  let(:root)       { prepare_example_project.read.send(:root) }
  let(:file_ref)   { root.project.main_group.file_ref('group1a/file2c.m') }
  let(:build_file) { root.project.target('example').sources_build_phase.send(:build_file, file_ref.uuid) }
  let(:obj)        { root.project.target('example').sources_build_phase }

  describe '#files' do
    it 'returns an array of files' do
      expect(obj.files).to be_a(Array)
      obj.files.each do |obj|
        expect(obj).to be_a(XcodeProject::PBXFileReference)
      end
    end
  end

  describe '#add_file' do
    context 'if passed an object of the PBXFileReference type' do
      it '=> add_build_file' do
        mock(obj).add_build_file(file_ref.uuid)
        obj.add_file(file_ref)
      end
    end

    context 'if passed an object of the PBXBuildFile type' do
      it '=> add_build_file_uuid' do
        mock(obj).add_build_file_uuid(build_file.uuid)
        obj.add_file(build_file)
      end
    end

    context 'if passed the object of unsupported type' do
      it 'raises an exception' do
        expect { obj.add_file(stub) }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#remove_file' do
    context 'if passed an object of the PBXFileReference type' do
      it '=> remove_build_file_uuid' do
        mock(obj).remove_build_file_uuid(root.project.target('example').sources_build_phase.send(:build_file, file_ref.uuid).uuid)
        obj.remove_file(file_ref)
      end
    end

    context 'if passed an object of the PBXBuildFile type' do
      it '=> remove_build_file_uuid' do
        mock(obj).remove_build_file_uuid(build_file.uuid)
        obj.remove_file(build_file)
      end
    end

    context 'if passed the object of unsupported type' do
      it 'raises an exception' do
        expect { obj.remove_file(stub) }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#build_files' do
    it 'returns an array of files' do
      expect(obj.send(:build_files)).to be_a(Array)
      obj.send(:build_files).each do |obj|
        expect(obj).to be_a(XcodeProject::PBXBuildFile)
      end
    end
  end

  describe '#build_file' do
    it 'returns the object' do
      expect(obj.send(:build_file, file_ref.uuid)).to be_a(XcodeProject::PBXBuildFile)
    end
  end

  describe '#add_build_file' do
    it 'adds the build file, returns the object' do
      expect(obj.send(:add_build_file, file_ref.uuid)).to be_a(XcodeProject::PBXBuildFile)
    end
  end

  describe '#remove_build_file' do
    it '=> remove_build_file_uuid' do
      mock(obj).remove_build_file_uuid(build_file.uuid)
      obj.send(:remove_build_file, file_ref.uuid)
    end
  end

  describe '#add_build_file_uuid' do
    it 'adds the build file uuid to the build list' do
      obj.send(:add_build_file_uuid, build_file.uuid)
      expect(obj.send(:build_files).map(&:uuid)).to include(build_file.uuid)
    end
  end

  describe '#remove_build_file_uuid' do
    it 'removes the build file uuid from the build list' do
      obj.send(:remove_build_file_uuid, build_file.uuid)
      expect(obj.send(:build_files).map(&:uuid)).not_to include(build_file.uuid)
    end
  end
end
