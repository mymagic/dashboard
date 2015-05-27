shared_examples "followable" do
  let(:follower) { create(:member, community: followable.community) }
  let(:adding_a_follower) { followable.followers << follower }
  describe 'adding a follower' do
    it 'adds a new follower' do
      expect { adding_a_follower }.
        to change { followable.followers.count }.by(1)
    end
  end
  context 'after adding a follower' do
    before { adding_a_follower }
    it "the follower#follwoers include the followable" do
      expect(follower.send("followed_#{ followable.class.table_name }")).to include(followable)
    end
  end
end
