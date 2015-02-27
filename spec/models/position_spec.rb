require 'rails_helper'

RSpec.describe Position, type: :model do
  context 'validations' do
    subject { build(:position) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }

    it { is_expected.to have_many(:companies_members_positions).dependent(:destroy) }
  end

  context 'class Methods' do
    describe '.positions_with_members' do
      xit 'includes only confirmed members' do

      end
      xit 'includes only approved companies members positions' do

      end
      xit 'orders the companies members positions by positions priority' do

      end
      xit 'returns a positions with members hash' do

      end
    end

    describe '.positions_in_companies' do
      xit 'includes only approved companies members positions' do

      end
      xit 'orders the companies members positions by positions priority' do

      end
      xit 'returns a companies with positions hash' do

      end
    end

    describe '.all_possible' do
      xit 'orders the positions' do

      end
      xit 'returns only positions that have not been requested by the member on that company yet' do

      end
    end
  end
end
