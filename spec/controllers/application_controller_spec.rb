require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  context 'magic_connect' do
    context 'with magic_cookie' do
      let(:magic_connect_id) { 123 }
      let(:email) { 'magic_connect_member@example.com' }
      let(:secret) { '98debabef5a280c7cf844c8682f787ea'}
      let(:cookie_value) { "#{ magic_connect_id }|||#{ email }|||#{ secret }" }

      before do
        cookies['magic_cookie'] = Base64.encode64(cookie_value)
        allow(controller).to receive(:valid_magic_cookie?).and_return(true)
      end

      describe 'magic_connect?' do
        it 'is true' do
          expect(controller.send(:magic_connect?)).to be_truthy
        end
      end

      describe 'magic_connect_id' do
        it 'returns the id' do
          expect(controller.send(:magic_connect_id)).to eq magic_connect_id
        end
      end

      describe 'magic_connect_email' do
        it 'returns the email' do
          expect(controller.send(:magic_connect_email)).to eq email
        end
      end

      describe 'magic_connect_member' do
        let(:community) { create(:community) }
        let!(:member) { create(:member, community: community, email: email) }
        before do
          allow(controller).to receive(:current_community).and_return(community)
        end
        it 'returns the member' do
          expect(controller.send(:magic_connect_member)).to eq member
        end
      end

      describe 'authorize_through_magic_connect!' do
        context 'with a magic_connect_member' do
          let(:community) { create(:community) }
          let!(:member) { create(:member, community: community, email: email) }
          before do
            allow(controller).
              to receive(:current_community).and_return(community)
            allow(controller).
              to receive(:magic_connect_member).and_return(member)
            allow(controller).
              to receive(:redirect_to)
          end

          it 'calls #update_magic_connect_id! on the member' do
            expect(member).
              to receive(:update_magic_connect_id!).with(magic_connect_id)
            controller.send(:authorize_through_magic_connect!)
          end

          it 'clears the flash alert messages' do
            expect(controller.flash).
              to receive(:delete).with(:alert)
            controller.send(:authorize_through_magic_connect!)
          end

          context 'who is confirmed' do
            before { allow(member).to receive(:confirmed?).and_return(true) }
            it 'signs the member in' do
              expect(controller).to receive(:sign_in).with(member)
              controller.send(:authorize_through_magic_connect!)
            end
          end
          context 'who is not confirmed' do
            before do
              allow(member).to receive(:confirmed?).and_return(false)
              allow(controller).
                to receive(:accept_invitation_url).and_return('invitation-url')
            end
            it 'redirects to the accept invitation url of the member' do
              expect(controller).to receive(:redirect_to).with('invitation-url')
              controller.send(:authorize_through_magic_connect!)
            end
          end
        end
      end
    end

    context 'without magic_cookie' do
      describe 'authorize_through_magic_connect!' do
        it 'returns nil' do
          expect(controller.send(:authorize_through_magic_connect!)).to be_nil
        end
      end
      describe 'magic_connect?' do
        it 'is false' do
          expect(controller.send(:magic_connect?)).to be_falsey
        end
      end
    end
  end
end
