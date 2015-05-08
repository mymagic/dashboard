require 'rails_helper'

RSpec.describe Tagging, type: :model do
  context 'validations' do
    subject { create(:discussion_tagging) }

    it { is_expected.to validate_presence_of(:taggable) }
    it { is_expected.to validate_presence_of(:tag) }
    it do
      is_expected.
        to validate_uniqueness_of(:tag_id).
        scoped_to(:taggable_id, :taggable_type)
    end
    it { is_expected.to belong_to(:tag).counter_cache(true) }
    it { is_expected.to belong_to(:taggable) }
  end
end
