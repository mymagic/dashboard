shared_examples "followable" do
  let(:follower) { create(:member, community: followable.try(:community) || followable.network.community) }
  let(:adding_a_follower) { Follow.create(member: follower, followable: followable, network: follower.default_network) }
  describe 'adding a follower' do
    it 'adds a new follower' do
      expect { adding_a_follower }.
        to change { followable.followers.count }.by(1)
    end
  end
  context 'after adding a follower' do
    before { adding_a_follower }
    it "the follower#followers include the followable" do
      expect(follower.send("followed_#{ followable.class.table_name }")).to include(followable)
    end
    it 'created a new follow activity' do
      expect(Activity::Following.find_by(owner: follower, followable: followable)).
        to_not be_nil
    end
  end
end
