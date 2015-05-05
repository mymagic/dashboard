require 'rails_helper'

RSpec.describe Message, type: :model do
  context 'validations' do
    subject { build(:message) }

    it { is_expected.to validate_presence_of(:sender) }
    it { is_expected.to validate_presence_of(:receiver) }
    it { is_expected.to validate_presence_of(:body) }
  end
end
