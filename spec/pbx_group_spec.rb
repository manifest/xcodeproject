require_relative 'spec_helper'
require_relative 'file_node_spec'

describe XcodeProject::PBXGroup do
  let(:root) { prepare_example_project.read.send(:root) }
  let(:obj)  { root.project.main_group.group('group1a') }

  describe '#children' do
    context 'if children exists' do
      it 'returns an array of children objects' do
        expect(obj.children).to be_a(Array)
        expect(obj.children.size).to be > 0
      end
    end

    context 'if children doesn\'t exist' do
      let(:empty_group_obj) { root.project.main_group.group('group1a/group2a') }

      it 'returns an empty array' do
        expect(empty_group_obj.children).to be_a(Array)
        expect(empty_group_obj.children.size).to eql(0)
      end
    end
  end

  describe '#files' do
    context 'if children exists' do
      it 'Returns an array of only those children who are files' do
        chs = obj.files
        expect(chs).to be_a(Array)
        expect(chs.size).to be > 0
        chs.each do |child|
          expect(child).to be_a(XcodeProject::PBXFileReference)
        end
      end
    end

    context 'if children doesn\'t exist' do
      let(:obj) { root.project.main_group.group('group1a/dir2c') }

      it 'returns an empty array' do
        chs = obj.files
        expect(chs).to be_a(Array)
        expect(chs.size).to eql(0)
      end
    end
  end

  describe '#groups' do
    context 'if children exists' do
      it 'Returns an array of only those children who are group' do
        chs = obj.groups
        expect(chs).to be_a(Array)
        expect(chs.size).to be > 0
        chs.each do |child|
          expect(child).to be_a(XcodeProject::PBXGroup)
        end
      end
    end

    context 'if children doesn\'t exist' do
      let(:obj) { root.project.main_group.group('group1a/dir2c/dir3a/dir4a') }

      it 'returns an empty array' do
        chs = obj.groups
        expect(chs).to be_a(Array)
        expect(chs.size).to eql(0)
      end
    end
  end

  describe '#child' do
    context "if passed '.'" do
      it 'returns the self' do
        expect(obj.child('.').uuid).to eql(obj.uuid)
      end
    end

    context "if passed '..'" do
      it 'returns the parent' do
        expect(obj.child('..').uuid).to eql(obj.parent.uuid)
      end
    end

    context 'if passed a child name' do
      it 'returns the child object' do
        [
          'group2a',
          'dir2c',
          'file2c.m'
        ].each do |name|
          expect(obj.child(name)).not_to be_nil
        end
      end
    end

    context 'if passed the group path' do
      it 'returns the child object' do
        [
          'dir2c/dir3a',
          'dir2c/dir3a/dir4a/file5a-a.m',
          'dir2c/dir3a/dir4a/file5a-r.m',
          'dir2c/../dir2c/dir3a/./dir4a/file5a-r.m'
        ].each do |gpath|
          expect(obj.child(gpath)).not_to be_nil
        end
      end
    end

    context 'if child doesn\'t exist' do
      it 'returns nil' do
        [
          'group2a_ghost',
          'group2a_ghost/file3c_ghost.m',
          'dir2c/file3c_ghost.m'
        ].each do |gpath|
          expect(obj.child(gpath)).to be_nil
        end
      end
    end
  end

  describe '#group?' do
    let(:dir_obj) { obj.child('dir2c') }

    context 'if the current group is abstract' do
      it 'returns true' do
        expect(obj.group?).to be true
      end
    end

    context 'if the current group is directory' do
      it 'returns false' do
        expect(dir_obj.group?).to be false
      end
    end
  end

  describe '#dir?' do
    let(:dir_obj) { obj.child('dir2c') }

    context 'if the current group is directory' do
      it 'returns true' do
        expect(dir_obj.dir?).to be true
      end
    end

    context 'if the current group is abstract' do
      it 'returns false' do
        expect(obj.dir?).to be false
      end
    end
  end

  describe '#group' do
    context 'if the group exists' do
      it 'returns the object' do
        expect(obj.group('group2a')).to be_a(XcodeProject::PBXGroup)
      end
    end

    context 'if the group doesn\'t exist' do
      it 'returns nil' do
        expect(obj.group('group2a_ghost')).to be nil
      end
    end
  end

  describe '#file_ref' do
    context 'if the file reference exists' do
      it 'returns the object' do
        expect(obj.file_ref('file2c.m')).to be_a(XcodeProject::PBXFileReference)
      end
    end

    context 'if the file reference doesn\'t exist' do
      it 'returns nil' do
        expect(obj.file_ref('file2c_ghost.m')).to be nil
      end
    end
  end

  describe '#add_file_ref' do
    context 'if passed the relative path' do
      it 'adds the file reference, returns the object' do
        expect(obj.send(:add_file_ref, 'dir1b/file2b.m')).to be_a(XcodeProject::PBXFileReference)
      end
    end

    context 'if passed the absolute path' do
      it 'adds the file reference, returns the object' do
        expect(obj.send(:add_file_ref, "#{example_project_dir}/dir1b/file2b.m")).to be_a(XcodeProject::PBXFileReference)
      end
    end

    context 'if file reference already exists' do
      it 'new object has same uuid as existing' do
        uuid = obj.file_ref('file2c.m').uuid
        expect(obj.send(:add_file_ref, 'dir1c/file2c.m').uuid).to eql(uuid)
      end
    end

    context 'if file doesn\'t exit' do
      it 'raise an exception' do
        expect { obj.send(:add_file_ref, 'file2c_ghost.m') }.to raise_exception(XcodeProject::FilePathError)
      end
    end
  end

  describe '#add_group' do
    it 'adds the group, returns the object' do
      group_obj = obj.add_group('group2a_ghost')
      expect(group_obj).to be_a(XcodeProject::PBXGroup)
      expect(group_obj.group?).to be true
    end
  end

  describe '#add_dir' do
    it 'adds the group, returns the object' do
      group_obj = obj.add_dir('dir1c')
      expect(group_obj).to be_a(XcodeProject::PBXGroup)
      expect(group_obj.dir?).to be true
    end

    it 'adds all dir\'s children' do
      obj.add_dir('dir1c')
      [
        obj.group('dir1c'),
        obj.group('dir1c/dir2c'),
        obj.file('dir1c/file2c.m')
      ].each do |obj|
        expect(obj).not_to be nil
      end
    end

    context 'if dir doesn\'t exit' do
      it 'raise an exception' do
        expect { obj.add_dir('dir2c_ghost') }.to raise_exception(XcodeProject::FilePathError)
      end
    end
  end

  describe '#create_group' do
    context 'if passed a group name' do
      it 'creates and returns the group object' do
        expect(obj.create_group('group2a_ghost')).to be_a(XcodeProject::PBXGroup)
      end
    end

    context 'if passed a group path' do
      it 'creates missed groups and returns the last group object' do
        [
          'group2a/group3a_ghost',
          'group2a_ghost/group3a_ghost',
          'group2a_ghost/../create_group2a_ghost/./group3a_ghost'
        ].each do |gpath|
          expect(obj.create_group(gpath)).to be_a(XcodeProject::PBXGroup)
        end
      end
    end

    context 'if group already exists' do
      it 'new object has same uuid as existing' do
        uuid = obj.child('group2a').uuid
        expect(obj.create_group('group2a').uuid).to eql(uuid)
      end
    end
  end

  describe '#remove_file_ref' do
    context 'if the file reference exists' do
      it 'removes the object' do
        obj.remove_file_ref('group1a/file2c.m')
        expect(obj.file_ref('group1a/file2c.m')).to be nil
      end
    end

    context 'if the file reference doesn\'t exist' do
      it 'returns nil' do
        expect(obj.remove_file_ref('group1a/file2c_ghost.m')).to be_nil
      end
    end
  end

  describe '#remove_group' do
    context 'if the group exists' do
      it 'removes the object' do
        obj.remove_group('group2a')
        expect(obj.group('group2a')).to be_nil
      end
    end

    context 'if the group doesn\'t exist' do
      it 'returns nil' do
        expect(obj.remove_group('group2a_ghost')).to be_nil
      end
    end
  end

  describe '#remove!' do
    it 'removes the current group' do
      obj.remove!
      expect(root.project.main_group.group('group1a')).to be_nil
    end
  end

  describe '#absolute_path' do
    let(:dir_obj) { root.project.main_group.group('group1a/dir2c/dir3a') }

    it 'makes the absolute path' do
      expect([
        'dir4a/file5a-a.m',
        "#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-a.m"
      ].map { |path| dir_obj.absolute_path(path) }).to eql([
                                                             Pathname.new("#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-a.m"),
                                                             Pathname.new("#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-a.m")
                                                           ])
    end
  end

  describe '#relative_path' do
    let(:dir_obj) { root.project.main_group.group('group1a/dir2c/dir3a') }

    it 'makes the relative path' do
      expect([
        'dir4a/file5a-a.m',
        "#{example_project_dir}/dir1a/dir2a/dir3a/dir4a/file5a-a.m"
      ].map { |path| dir_obj.relative_path(path) }).to eql([
                                                             Pathname.new('dir4a/file5a-a.m'),
                                                             Pathname.new('dir4a/file5a-a.m')
                                                           ])
    end
  end

  it_behaves_like 'a file node' do
    let(:main_group) do
      root.project.main_group
    end

    let(:file_nodes_gpaths) do
      [
        'group1a/dir2c/dir3a/dir4a',
        'group1a/dir2c/dir3a',
        'group1a/dir2c',
        'group1a/group2a',
        'group1a'
      ]
    end

    let(:file_nodes_total_paths) do
      [
        "#{example_project_dir}/dir1a/dir2a/dir3a/dir4a",
        "#{example_project_dir}/dir1a/dir2a/dir3a",
        "#{example_project_dir}/dir1c/dir2c",
        example_project_dir,
        example_project_dir
      ]
    end
  end
end
