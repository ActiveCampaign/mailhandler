require 'spec_helper'

describe MailHandler::Receiving::Notification::Email do

  let(:search) { double('search') }
  let(:sender) { double('sender') }
  let(:notification) { MailHandler::Receiving::Notification::Email.new(sender, 'igor@example.com',1) }

  before(:each) do

    allow(sender).to receive(:send_email) { true }
    allow(search).to receive(:max_duration) { 5 }

  end

  it '.create' do

    aggregate_failures "init details" do

      expect(notification.min_time_to_notify).to eq 1
      expect(notification.max_time_to_notify).to eq nil
      expect(notification.contacts).to eq 'igor@example.com'
      expect(notification.sender).to eq sender

    end

  end

  it '.notify' do

    allow(search).to receive(:started_at) { Time.now }
    notification.notify(search)
    expect(notification.max_time_to_notify).to eq search.max_duration

  end

  context 'states' do

    it 'no delay' do

      allow(search).to receive(:started_at) { Time.now }
      notification.notify(search)
      expect(notification.current_state).to be_kind_of MailHandler::Receiving::Notification::NoDelay

    end

    it 'delayed' do

      allow(search).to receive(:started_at) { Time.now - 2}
      allow(search).to receive(:result) { false }
      allow(notification).to receive(:send_email) { }
      notification.notify(search)
      expect(notification.current_state).to be_kind_of MailHandler::Receiving::Notification::Delay

    end

    it 'received' do

      allow(search).to receive(:started_at) { Time.now - 2}
      allow(search).to receive(:result) { true }
      allow(notification).to receive(:send_email) { }
      notification.notify(search)
      expect(notification.current_state).to be_kind_of MailHandler::Receiving::Notification::Received

    end

    it 'max delayed' do

      allow(search).to receive(:started_at) { Time.now - 10}
      allow(search).to receive(:result) { false }
      allow(notification).to receive(:send_email) { }
      notification.notify(search)
      expect(notification.current_state).to be_kind_of MailHandler::Receiving::Notification::MaxDelay

    end

  end

end