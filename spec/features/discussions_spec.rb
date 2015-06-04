require 'rails_helper'

RSpec.describe 'Discussion', type: :feature, js: false do
  shared_examples "browsing the discussions page" do
    it "lists all discussions and a link to a new discussion" do
      visit community_discussions_path(community)
      expect(page).to have_content 'Discussions'
      expect(page).to have_link 'Start a new Discussion'
      expect(page).to have_content 'To be or not to be?'
      expect(page).to have_content 'Posted by William Shakespeare'
    end
  end

  shared_examples "removing a discussion" do
    it "removes the discussion" do
      visit community_discussions_path(community)
      click_link 'To be or not to be?'
      click_link 'Remove this Discussion'
      expect(page).to have_content 'Discussion was successfully deleted.'
      expect(page).to_not have_content 'To be or not to be?'
    end
  end

  shared_examples "removing a comment" do
    it "removes a comment" do
      visit community_discussions_path(community)
      click_link 'To be or not to be?'
      click_link 'Remove this Comment'
      expect(page).to have_content 'Comment was successfully deleted.'
      expect(page).to have_content 'To be or not to be?'
    end
  end


  shared_examples "adding a comment" do
    it "adds a new comment to a discussion" do
      visit community_discussions_path(community)
      click_link 'To be or not to be?'
      within '#new_comment' do
        fill_in 'Body', with: 'Definitely to be.'
        click_button 'Post'
      end
      expect(page).to have_content 'Comment was successfully created.'
      expect(page).to have_content 'Definitely to be.'
    end
  end

  shared_examples "following and unfollowing a discussion" do
    it "follows and unfollows a discussion" do
      visit community_discussions_path(community)
      click_link 'To be or not to be?'
      within '.page-header' do
        expect(page).to have_content 'To be or not to be?'
      end
      within '.page-header' do
        click_link 'Follow'
      end
      expect(page).to have_content 'You are now following the discussion.'
    end
  end

  shared_examples "creating a new discussion" do
    it "creates a new discussion" do
      visit community_discussions_path(community)
      click_link 'Start a new Discussion'
      fill_in 'Title',  with: 'What is beauty?'
      fill_in 'Body',  with: 'By means of beauty all beautiful '\
                             'things become beautiful.'
      fill_in 'Tags', with: 'wonderful_tag, great_tag, wonderful_tag'
      click_button 'Post'
      expect(page).to have_content 'Discussion was successfully created.'
      within '.page-header' do
        expect(page).to have_content 'What is beauty?'
      end
      expect(page).to have_link 'wonderful_tag', count: 1
      expect(page).to have_link 'great_tag', count: 1
      expect(page).to have_content 'By means of beauty all beautiful '\
                                   'things become beautiful.'
    end
  end

  shared_examples "filtered by tags" do
    it "filters discussions by tags" do
      visit community_discussions_path(community)
      click_link 'To be or not to be?'
      click_link 'Best Tag'
      expect(page).to have_content 'Discussions tagged with Best Tag'
      expect(page).to have_content 'To be or not to be?'
    end
  end


  feature "Company Member Invitation" do
    given!(:community) { create(:community) }
    given(:administrator) do
      create(:administrator, :confirmed, community: community)
    end
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:mentor) { create(:mentor, :confirmed, community: community) }
    given(:member) { create(:member, :confirmed, community: community) }
    given!(:discussion) do
      create(
        :discussion,
        tag_list: 'Best Tag',
        author: create(
          :member,
          :confirmed,
          first_name: 'William',
          last_name: 'Shakespeare',
          community: community),
        title: 'To be or not to be?',
        body: 'That is the question'
      )
    end
    given!(:comment) do
      create(:comment, author: discussion.author, discussion: discussion)
    end

    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "browsing the discussions page"
      it_behaves_like "creating a new discussion"
      it_behaves_like "following and unfollowing a discussion"
      it_behaves_like "adding a comment"
      it_behaves_like "removing a discussion"
      it_behaves_like "filtered by tags"
      it_behaves_like "removing a comment"
    end

    context 'as staff' do
      background { as_user staff }
      it_behaves_like "browsing the discussions page"
      it_behaves_like "creating a new discussion"
      it_behaves_like "following and unfollowing a discussion"
      it_behaves_like "adding a comment"
      it_behaves_like "filtered by tags"
    end

    context 'as mentor' do
      background { as_user mentor }
      it_behaves_like "browsing the discussions page"
      it_behaves_like "creating a new discussion"
      it_behaves_like "following and unfollowing a discussion"
      it_behaves_like "adding a comment"
      it_behaves_like "filtered by tags"
    end

    context 'as member' do
      background { as_user member }
      it_behaves_like "browsing the discussions page"
      it_behaves_like "creating a new discussion"
      it_behaves_like "following and unfollowing a discussion"
      it_behaves_like "adding a comment"
      it_behaves_like "filtered by tags"
    end
  end
end