require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  describe "GET #index" do
    let(:community) { create(:community) }
    let(:response) { get(:index, community_id: community) }
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
        get :index, community_id: community
      end
      it 'assigns the correct active members' do
        expect(assigns(:members)).to contain_exactly(member, active_member)
      end
    end
  end

  describe "GET #show" do
    let(:community) { create(:community) }
    let(:member) { create(:member, community: community) }
    let(:response) { get(:show, id: member, community_id: community) }
    it_behaves_like(
      "accessible by", :administrator, :mentor, :staff, :regular_member
    )
  end

  describe "POST #create" do
    let(:member_required_attributes) { { email: 'email@example.com' } }
    let(:community) { create(:community) }
    let(:company) { create(:company, community: community) }

    def invite_new_member(attributes = {})
      post(
        :create,
        community_id: company.community,
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
        create(
          :companies_members_position,
          :approved,
          :managable,
          position: position,
          member: member,
          company: company
        )
        login(member)
      end

      describe 'inviting a Member to the company' do
        before do
          invite_new_member(
            companies_positions_attributes: [
              position_id: position.id,
              approver_id: member.id
            ]
          )
        end

        subject(:invited_member) {
          Member.find_by(email: member_required_attributes[:email])
        }

        it 'invites a regular member' do
          expect(invited_member).to be_regular_member
        end

        it "sets the cmp's approver to the current member" do
          expect(invited_member.companies_positions.first.approver).
            to eq(member)
        end

        it "sets the cmp's company to the current company" do
          expect(invited_member.companies_positions.first.company).
            to eq(company)
        end
      end

      describe 'inviting an existing member' do
        let(:existing_member) do
          create(:member, :confirmed, community: community)
        end
        subject do
          invite_new_member(
            email: existing_member.email,
            companies_positions_attributes: [
              position_id: position.id
            ]
          )
        end
        context 'with a new member position at that company' do
          it 'just adds the position' do
            expect { subject }.
              to change { existing_member.companies_positions.count }.
              from(1).to(2)
          end
          it 'redirects to the community company path' do
            expect(subject).
              to redirect_to(
                community_company_path(community, company))
          end
        end
        context 'with already having that position at that company' do
          before do
            create(
              :companies_members_position,
              :approved,
              position: position,
              member: existing_member,
              company: company
            )
          end
          it 'does not add a new position' do
            expect { subject }.
              to_not change { existing_member.companies_positions.count }
          end
          it 'redirects to the community company path' do
            expect(subject).
              to redirect_to(
                new_community_company_member_path(community, company))
          end
        end
      end
    end

    context 'as Administrator' do
      let(:member) do
        create(:administrator, :confirmed, community: community)
      end
      let(:position) { create(:position, community: community) }

      before { login(member) }

      describe 'inviting a Member to the company' do
        before do
          invite_new_member(
            companies_positions_attributes: [
              position_id: position.id
            ]
          )
        end

        subject(:invited_member) {
          Member.find_by(email: member_required_attributes[:email])
        }

        it 'invites a regular member' do
          expect(invited_member).to be_regular_member
        end

        it "sets the cmp's approver to the current member" do
          expect(invited_member.companies_positions.first.approver).
            to eq(member)
        end

        it "sets the cmp's company to the current company" do
          expect(invited_member.companies_positions.first.company).
            to eq(company)
        end
      end
    end
  end
end
