require 'rails_helper'

RSpec.describe Community, type: :model do
  context 'validations' do
    subject { FactoryGirl.create(:community) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  context 'after_create' do
    let(:community) { build(:community) }
    it 'should have all the default SocialMediaServices' do
      expect(community.social_media_services).to be_empty
      community.save
      expect(community.reload.social_media_services).to include('googleplus')
    end
    it 'should set an email' do
      expect(community.email).to be_blank
      community.save
      expect(community.reload.email).to match(/noreply@/)
    end
  end
end
