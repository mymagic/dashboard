require 'rails_helper'

RSpec.describe SocialMediaLink, type: :model do
  context 'validations' do
    subject { FactoryGirl.build(:social_media_link, :member) }

    it { is_expected.to validate_presence_of(:attachable) }
    it { is_expected.to validate_presence_of(:service) }
    it { is_expected.to validate_presence_of(:handle) }
    it { is_expected.to validate_uniqueness_of(:handle).scoped_to(:service) }
    it { is_expected.to validate_inclusion_of(:service).in_array(SocialMediaLink::SERVICES) }
  end

  context 'associations' do
    it { should belong_to(:attachable) }
  end
end
