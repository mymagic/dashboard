require 'rails_helper'

class FakesController < ApplicationController
  include TagsConcern
end

RSpec.describe FakesController, type: :controller do
  class FakeTag < Tag; end
  describe 'tags_class' do
    it 'should build the correct Tags Class' do
      expect(subject.send(:tags_class)).to eq(FakeTag)
    end
  end

  describe 'current_tag' do
    before do
      allow(subject).to receive(:tags_class).and_return(FakeTag)
      allow(subject).to receive(:params).and_return(tag_id: tag_id)
    end
    context 'with a tag_id' do
      let(:tag_id) { 123 }
      it 'finds the tag by :tag_id' do
        expect(FakeTag).to receive(:find).with(tag_id).and_return('tag')
        expect(subject.send(:tag)).to eq('tag')
      end
    end
    context 'without a tag_id' do
      let(:tag_id) {}
      it 'returns nil' do
        expect(FakeTag).to_not receive(:find).with(tag_id)
        expect(subject.send(:tag)).to be_nil
      end
    end
  end
end
