require_relative 'spec_helper'

describe XcodeProject::XCBuildConfiguration do
  let(:obj) { @data.target('example').config('Release') }

  before(:each) do
    @data = prepare_example_project.read
  end

  describe '#plist_path' do
    it 'returns plist file path' do
      expect(obj.send(:plist_path)).to eql(example_project_dir.join('example/example-Info.plist'))
    end
  end

  describe '#version' do
    context 'by default' do
      it 'returns major version' do
        expect(obj.version).to eql(obj.version(:major))
      end
    end

    context 'if passed :major' do
      it 'returns major version' do
        expect(obj.version(:major)).to eql('1.0')
      end
    end

    context 'if passed :minor' do
      it 'returns minor version' do
        expect(obj.version(:minor)).to eql('345')
      end
    end

    context 'if passed :both' do
      it 'returns both, major and minor versions' do
        expect(obj.version(:both)).to eql('1.0.345')
      end
    end
  end

  describe '#change_version' do
    let(:version) { '2.0' }

    context 'by default' do
      it 'changes major version' do
        obj.change_version(version)
        expect(obj.version(:major)).to eql(version)
      end
    end

    context 'if passed :major' do
      it 'changes major version' do
        obj.change_version(version, :major)
        expect(obj.version(:major)).to eql(version)
      end
    end

    context 'if passed :minor' do
      it 'changes minor version' do
        obj.change_version(version, :minor)
        expect(obj.version(:minor)).to eql(version)
      end
    end
  end

  describe '#increment_version' do
    context 'by default' do
      let(:next_version) { '1.1' }

      it 'increments major version' do
        obj.increment_version
        expect(obj.version(:major)).to eql(next_version)
      end
    end

    context 'if passed :major' do
      let(:next_version) { '1.1' }

      it 'increments major version' do
        obj.increment_version(:major)
        expect(obj.version(:major)).to eql(next_version)
      end
    end

    context 'if passed :minor' do
      let(:next_version) { '346' }

      it 'increments minor version' do
        obj.increment_version(:minor)
        expect(obj.version(:minor)).to eql(next_version)
      end
    end
  end

  describe '#read_property' do
    let(:key) { 'CFBundleShortVersionString' }
    let(:value) { '1.0' }

    it 'read a property by key from plist file' do
      expect(obj.send(:read_property, key)).to eql(value)
    end
  end

  describe '#write_property' do
    let(:key)   { 'CFBundleShortVersionString' }
    let(:value) { '1.1' }

    it 'write value by key to plist file' do
      obj.send(:write_property, key, value)
      expect(obj.send(:read_property, key)).to eql(value)
    end
  end
end
