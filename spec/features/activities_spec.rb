require 'rails_helper'

RSpec.describe 'Activities', type: :feature, js: false do
  def create_member(full_name)
    create(
      :member,
      :confirmed,
      community: community,
      first_name: full_name.split(' ')[0],
      last_name: full_name.split(' ')[1])
  end

  def create_discussion(title, author: nil)
    create(
      :discussion,
      author: author || create(:member, :confirmed, community: community),
      network: network,
      title: title
    )
  end

  def create_comment(author: nil, discussion: nil)
    discussion ||= create(
      :discussion,
      author: create(:member, :confirmed, community: community))
    create(
      :comment,
      author: author || create(:member, :confirmed, community: community),
      discussion: discussion
    )
  end

  shared_examples "stream with followed members and discussions" do
    it "has a valid stream" do
      [
        'Alice Allison started following Dan Danski',
        'Alice Allison started following all about singularity',
        'Alice Allison started discussion The Truth About Bob',
        'Alice Allison added a comment to The Future Tomorrow',
        'Dan Danski added a comment to Adventures by Alice',
        'Alice Allison is not attending Hackweek'
      ].each do |content|
        expect(page).to have_content(content)
      end
      expect(page).to_not have_content 'Other Community'
    end
  end

  {
    to: 'stream with other members and discussions',
    to_not: 'stream without other members and discussions'
  }.each do |expectation, title|
    shared_examples title do
      it "has a valid stream" do
        [
          'Bob Bobsy started following Eddy Edward',
          'Bob Bobsy is attending Hackweek'
        ].each do |content|
          expect(page).send(expectation, have_content(content))
        end
        expect(page).to_not have_content 'Other Community'
      end
    end
  end

  feature "Activities Stream" do
    given(:community) { create(:community) }
    given(:network) { community.networks.first }
    given(:member) { create(:member, :confirmed, community: community) }

    given(:alice) { create_member('Alice Allison') }
    given(:dan) {   create_member('Dan Danski') }
    given(:bob) {   create_member('Bob Bobsy') }

    given(:followed_discussion) { create_discussion('Adventures by Alice') }

    context 'with no activities' do
      context 'as a member' do
        background do
          as_user member
        end
        feature "viewing the public stream" do
          background { visit community_path(community) }
          it 'shows a notification that there are no activities yet' do
            expect(page).to have_content("Sorry, there is nothing to see yet.")
          end
        end
        feature "viewing the personal stream" do
          background { visit community_path(community, filter: 'personal') }
          it 'shows a notification that there are no activities yet' do
            expect(page).to have_content("Sorry, there is nothing to see yet.")
          end
        end
      end
    end

    context 'with some activities' do
      # FollowActivities
      # given!(:alice_following_dan) { alice.followed_members << dan }
      given!(:alice_following_dan) { Follow.create(member: alice, followable: dan, network: network)}
      given!(:alice_following_a_discussion) do
        alice.followed_discussions << create_discussion('all about singularity')
      end
      given!(:bob_following_a_member) do
        Follow.create(member: bob, followable: create_member('Eddy Edward'), network: network)
      end

      # DiscussionActivities
      given!(:alice_creating_a_discussion) do
        create_discussion('The Truth About Bob', author: alice)
      end

      # CommentActivities
      given!(:alice_creating_a_comment) do
        create_comment(
          author: alice,
          discussion: create_discussion('The Future Tomorrow'))
      end
      given!(:commenting_on_followed_discussion) do
        create_comment(author: dan, discussion: followed_discussion)
      end

      # RsvpActivities
      given!(:event) { create(:event, network: network, title: 'Hackweek') }
      given!(:alice_rsvping_to_an_event) do
        alice.rsvps.create(event: event, state: 'not_attending')
      end
      given!(:bob_rsvping_to_an_event) do
        bob.rsvps.create(event: event, state: 'attending')
      end

      given!(:activity_in_other_community) do
        network_in_other_community = create(:community).networks.first
        create(
          :discussion,
          network: network_in_other_community,
          title: 'Other Community')
      end

      context 'as a member, following some people and discussions' do
        background do
          Follow.create(member: member, followable: alice, network: network)
          member.followed_discussions << followed_discussion
          as_user member
        end
        feature "viewing the public stream" do
          background do
            visit community_network_path(community, network)
          end
          it_behaves_like(
            "stream with followed members and discussions")
          it_behaves_like(
            "stream with other members and discussions")
        end
        feature "viewing the personal stream" do
          background { visit community_network_path(community, network, filter: 'personal') }
          it_behaves_like(
            "stream with followed members and discussions")
          it_behaves_like(
            "stream without other members and discussions")
        end
      end
    end
  end
end
