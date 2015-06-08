require 'rails_helper'

RSpec.describe Notifier, type: :module do
  let(:member) { build(:member) }
  describe '.deliver' do
    subject do
      Notifier.deliver(
        :message_notification,
        member,
        key1: 'value1',
        key2: 'value2')
    end
    context 'with a type that the receiver does not want to receive' do
      before { allow(member).to receive(:receive?).and_return(false) }
      it { is_expected.to be_nil }
    end
    context 'with a type that the receiver wants to receive' do
      let(:mailer) { double('notification_mailer') }
      before do
        allow(member).to receive(:receive?).and_return(true)
        allow(mailer).to receive(:deliver_later)
      end
      it 'calls notification mailer with correct arguments' do
        expect(NotificationMailer).
          to receive(:message_notification).
          with(member, key1: 'value1', key2: 'value2').and_return(mailer)
        subject
      end
    end
  end
end
