require 'rails_helper'

RSpec.describe Position, type: :model do
  context 'validations' do
    subject { build(:position) }
    it { is_expected.to validate_presence_of(:company) }
    it { is_expected.to validate_presence_of(:member) }
  end
end
