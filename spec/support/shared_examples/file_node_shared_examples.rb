shared_examples 'a file node' do
  describe '#parent' do
    context 'if the object is nested file node' do
      it 'returns the parent object' do
        file_nodes_gpaths do |gpath|
          expect(main_group.child(gpath).parent).to be_a(XcodeProject::PBXGroup)
        end
      end
    end
  end

  describe '#group_path' do
    it 'returns the abstract path from project main group' do
      expect(file_nodes_gpaths.map { |gpath|
        main_group.child(gpath).group_path
      }).to eql(file_nodes_gpaths.map { |gpath| Pathname.new(gpath) })
    end
  end

  describe '#total_path' do
    it 'returns the absolute file path' do
      expect(file_nodes_gpaths.map { |gpath|
        main_group.child(gpath).total_path
      }).to eql(file_nodes_total_paths.map { |gpath| Pathname.new(gpath) })
    end
  end
end
