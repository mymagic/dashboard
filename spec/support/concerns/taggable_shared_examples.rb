shared_examples "taggable" do
  describe 'adding a tag' do
    let(:adding_a_tag) { subject.add_tag('Technology') }
    it 'adds a new tag' do
      expect { adding_a_tag }.to change { subject.tags.count }.from(0).to(1)
    end
    it 'returns a tag' do
      expect(adding_a_tag).to be_a(subject.class.send(:tags_class))
    end
  end
  describe 'removing a tag' do
    let!(:new_tag) { subject.add_tag('Technology') }
    let(:removing_a_tag) { subject.remove_tag('Technology') }
    it 'removes the tag' do
      expect { removing_a_tag }.to change { subject.tags.count }.from(1).to(0)
    end
  end
end
