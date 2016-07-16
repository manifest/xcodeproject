require_relative 'spec_helper'

describe XcodeProject::FileNode do
  let(:data_name)      { Hash['name', 'file.name'] }
  let(:data_path)      { Hash['path', 'path/to/file.name'] }
  let(:data_path_name) { data_path.merge!(data_name) }
  let(:data_empty)     { Hash.new }

  describe '#name' do
    context 'if the name is initialized' do
      it 'returns the name as is' do
        [data_name, data_path_name].each do |data|
          expect(XcodeProject::FileNode.new(stub, stub, data).name).to eql(data['name'])
        end
      end
    end

    context 'if the name isn\'t initialized' do
      context 'and the path is initialized ' do
        it 'returns the name as basename of the path' do
          expect(XcodeProject::FileNode.new(stub, stub, data_path).name).to eql(File.basename(data_path['path']))
        end
      end

      context 'and the path isn\'t initialized' do
        it 'returns nil' do
          expect(XcodeProject::FileNode.new(stub, stub, data_empty).name).to be_nil
        end
      end
    end
  end

  describe '#path' do
    context 'if the path is initialized' do
      it 'returns the path as is' do
        [data_path, data_path_name].each do |data|
          expect(XcodeProject::FileNode.new(stub, stub, data_path).path).to eql(data['path'])
        end
      end
    end

    context 'if the path isn\'t initialized' do
      it 'returns nil' do
        expect(XcodeProject::FileNode.new(stub, stub, data_empty).path).to be_nil
      end
    end
  end

  describe '#parent' do
    let(:root) { prepare_example_project.read.send(:root) }

    context 'if the current object is the main group' do
      it 'returns nil' do
        expect(root.project.main_group.parent).to be_nil
      end
    end
  end
end
