require_relative 'spec_helper'

describe XcodeProject::Project do
  let(:proj) { prepare_example_project }

  describe '#new' do
    context 'if the project file exists' do
      it 'constructs an project object' do
        expect(XcodeProject::Project.new(example_project_bundle_path)).to be_a(XcodeProject::Project)
      end
    end

    context 'if the project file doesn\'t exist' do
      let(:proj_ne) { "#{example_empty_sandbox_path}/ghost.xcodeproj" }
      it 'throws the exception' do
        expect { XcodeProject::Project.new(proj_ne) }.to raise_exception(XcodeProject::FilePathError)
      end
    end
  end

  describe '#file_path' do
    it 'returns the project\'s file path' do
      expect(proj.file_path).to eql(example_project_file_path)
    end
  end

  describe '#bundle_path' do
    it 'returns the project\'s bundle path' do
      expect(proj.bundle_path).to eql(example_project_bundle_path)
    end
  end

  describe '#find' do
    context 'if a specified directory contains project files' do
      it 'returns an array of project objects' do
        projs = XcodeProject::Project.find(example_project_bundle_path)
        expect(projs.size).to eql(1)
        expect(projs.first.bundle_path).to eql(proj.bundle_path)
      end
    end

    context 'if a specified directory pattern contains project files' do
      it 'returns an array of project objects' do
        projs = XcodeProject::Project.find("#{example_sandbox_path}/*")
        expect(projs.size).to eql(1)
        expect(projs.first.bundle_path).to eql(proj.bundle_path)
      end
    end

    context 'if a specified directory doesn\'t contain project files' do
      it 'returns an empty array' do
        projs = XcodeProject::Project.find(example_empty_sandbox_path)
        expect(projs.size).to eql(0)
      end
    end
  end

  describe '#read' do
    it 'returns the data object' do
      expect(proj.read).to be_a(XcodeProject::Data)
    end

    it 'reads the project file' do
      mock.proxy(proj).file_path
      proj.read
    end
  end

  describe '#write' do
    it 'writes the project file' do
      data = proj.read

      mock.proxy(proj).file_path
      proj.write(data)
    end
  end

  describe '#change' do
    it 'reads the file file and then writes it' do
      proj_mock = mock.proxy(proj)
      proj_mock.read
      proj_mock.write(is_a(XcodeProject::Data))
      proj.change { |_data| }
    end
  end
end
