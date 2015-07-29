require 'rails_helper'

RSpec.describe MagicConnect, type: :module do
  before do
    allow(ENV).
      to receive(:[]).with("magic_api_username").and_return("username")
    allow(ENV).
      to receive(:[]).with("magic_api_password").and_return("password")
  end
  describe '.user_exists?' do
    let(:email) { 'user@example.com' }
    subject { MagicConnect.user_exists?(email) }
    before do
      stub_request(
        :get,
        "http://username:password@connect.mymagic.my/api/get-user-by-email/"\
        "?email=#{ email }"
      ).to_return(status: response_code, body: response_body, headers: {})
    end

    context 'with a non existing user' do
      let(:response_code) { 200 }
      let(:response_body) do
        { "error": "A user could not be found with a login "\
                   "value of [#{ email }]." }.to_json
      end
      it { is_expected.to be_falsey }
    end

    context 'with an existing user' do
      let(:response_code) { 200 }
      let(:response_body) { { "data": { "email": email } }.to_json }
      it { is_expected.to be_truthy }
    end
  end

  describe '.create_user!' do
    let(:email) { 'user@example.com' }
    let(:first_name) { 'Frank' }
    let(:last_name) { 'Sinatra' }
    subject { MagicConnect.create_user!(first_name, last_name, email) }
    before do
      stub_request(
        :post,
        "http://username:password@connect.mymagic.my/api/signup/"
      ).with(
        body: {
          first_name: first_name,
          last_name: last_name,
          email: email
        }
      ).to_return(status: response_code, body: response_body, headers: {})
    end

    context 'with successful user creation' do
      let(:response_code) { 200 }
      let(:response_body) do
        { "message": "Success" }.to_json
      end
      it { is_expected.to be_truthy }
    end

    context 'with an error' do
      let(:response_code) { 400 }
      let(:response_body) do
        {
          "error": {
            "email": ["an user with that email already exists."]
          }
        }.to_json
      end
      it { is_expected.to be_falsey }
    end
  end
end
