require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  describe "GET #index" do
    it_behaves_like "accessible by everyone except unauthenticated" do
      let(:response) { get(:index) }
    end
  end

  describe "GET #show" do
    let(:member) { create(:member) }
    it_behaves_like "accessible by everyone except unauthenticated" do
      let(:response) { get(:show, id: member) }
    end
  end
end
