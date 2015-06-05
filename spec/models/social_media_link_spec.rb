require 'rails_helper'

RSpec.describe SocialMediaLink, type: :model do
  context 'validations' do
    subject { FactoryGirl.build(:social_media_link, :member) }

    it { is_expected.to validate_presence_of(:attachable) }
    it { is_expected.to validate_presence_of(:service) }

    it do
      is_expected.to validate_uniqueness_of(:service).
        scoped_to(:attachable_id, :attachable_type)
    end
    it do
      is_expected.to validate_inclusion_of(:service).
        in_array(subject.attachable.community.social_media_services)
    end

    it do
      is_expected.
        to allow_value('https://example.com', 'http://example.com').for(:url)
    end
    it do
      is_expected.
        to_not allow_value('ht://example.com', 'ftp://example.com').for(:url)
    end
  end

  context 'associations' do
    it { should belong_to(:attachable) }
  end
end
