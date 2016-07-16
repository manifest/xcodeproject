require_relative 'spec_helper'
require 'file_node_spec'

describe XcodeProject::PBXFileReference do
  let(:root)      { prepare_example_project.read.send(:root) }
  let(:obj_gpath) { 'group1a/file2c.m' }
  let(:obj)       { root.project.main_group.file_ref(obj_gpath) }

  describe '#remove!' do
    it 'removes the current file reference' do
      obj.remove!
      expect(root.project.main_group.file_ref(obj_gpath)).to be_nil
    end

    it 'removes build files which has been bonded with the current file reference' do
      obj.remove!
      expect(root.build_files(obj.uuid)).to be_empty
    end
  end

  it_behaves_like 'a file node' do
    let(:main_group) do
      root.project.main_group
    end

    let(:file_nodes_gpaths) do
      [
        'group1a/dir2c/dir3a/dir4a/file5a-a.m',
        'group1a/dir2c/dir3a/dir4a/file5a-r.m',
        'group1a/file2c.m'
      ]
    end

    let(:file_nodes_total_paths) do
      [
        "#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-a.m",
        "#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-r.m",
        "#{example_project_dir}/dir1c/file2c.m"
      ]
    end
  end
end
