require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  let(:community) { create(:community) }
  let(:network) { community.default_network }

  describe "GET #index" do
    let(:response) { get(:index, community_id: community, network_id: network) }
    let(:members) { Member }
    it_behaves_like(
      "accessible by", :administrator, :mentor, :staff, :regular_member
    )
    describe 'assigning members' do
      let!(:active_member) { create(:member, :confirmed, community: community) }
      let!(:invited_member) { create(:member, :invited, community: community) }
      let!(:member) { create(:member, :confirmed, community: community) }
      before do
        login(member)
        stub_valid_cookie
        get :index, community_id: community, network_id: network
      end
      it 'assigns the correct active members' do
        expect(assigns(:members)).to contain_exactly(member, active_member)
      end
    end
  end

  describe "GET #show" do
    let(:member) { create(:member, community: community) }
    let(:response) { get(:show, id: member, community_id: community, network_id: network) }
    it_behaves_like(
      "accessible by", :administrator, :mentor, :staff, :regular_member
    )
  end

  describe "POST #create" do
    let(:member_required_attributes) do
      {
        email: 'email@example.com',
        positions_attributes: [
          role: '',
          founder: '0'
        ]
      }
    end
    let(:company) { create(:company, community: community) }

    def invite_new_member(attributes = {})
      post(
        :create,
        community_id: company.community,
        network_id: company.default_network,
        company_id: company,
        member: (member_required_attributes).merge(attributes)
      )
    end

    it_behaves_like "accessible by", :administrator, :staff do
      let(:response) { invite_new_member }
    end

    context 'as manager of company' do
      let(:member) { create(:member, :confirmed, community: community) }
      let(:position) { create(:position, community: community) }
      before do
        create(:position, founder: true, member: member, company: company)
        login(member)
        stub_valid_cookie
      end

      describe 'inviting a Member to the company' do
        before { invite_new_member }

        subject(:invited_member) do
          Member.find_by(email: member_required_attributes[:email])
        end

        it 'invites a regular member' do
          expect(invited_member).to be_regular_member
        end

        it "sets the cmp's company to the current company" do
          expect(invited_member.companies.first).to eq(company)
        end
      end

      describe 'inviting an existing member' do
        let(:existing_member) do
          create(:member, :confirmed, community: community)
        end
        subject do
          stub_valid_cookie
          invite_new_member(email: existing_member.email)
        end
        context 'with a new member position at that company' do
          it 'just adds the position' do
            expect { subject }.
              to change { existing_member.positions.count }.from(1).to(2)
          end
          it 'redirects to the community company path' do
            expect(subject).
              to redirect_to([community, network, company])
          end
        end
        context 'with already having that position at that company' do
          before do
            create(:position,
                   member: existing_member,
                   company: company,
                   role: '')
          end
          it 'does not add a new position' do
            expect { subject }.
              to_not change { existing_member.positions.count }
          end
          it 'redirects to the new community company member path' do
            expect(subject).
              to redirect_to(
                new_community_network_company_member_path(community, network, company))
          end
        end
      end
    end

    context 'as Administrator' do
      let(:member) do
        create(:administrator, :confirmed, community: community)
      end

      before do
        login(member)
        stub_valid_cookie
      end

      describe 'inviting a Member to the company' do
        before { invite_new_member }

        subject(:invited_member) do
          Member.find_by(email: member_required_attributes[:email])
        end

        it 'invites a regular member' do
          expect(invited_member).to be_regular_member
        end

        it "sets the cmp's company to the current company" do
          expect(invited_member.companies.first).to eq(company)
        end
      end
    end
  end
end
