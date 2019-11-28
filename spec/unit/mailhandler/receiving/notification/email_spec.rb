# frozen_string_literal: true

require 'spec_helper'

describe MailHandler::Receiving::Notification::Email do
  let(:search) { instance_double('search') }
  let(:sender) { instance_double('sender') }
  let(:notification) { described_class.new(sender, 'from@example.com', 'igor@example.com', 1) }

  before do
    allow(sender).to receive(:send_email).and_return(true)
    allow(search).to receive(:max_duration).and_return(5)
  end

  it '.create' do
    aggregate_failures 'init details' do
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
      allow(search).to receive(:started_at) { Time.now - 2 }
      allow(search).to receive(:result).and_return(false)
      allow(notification).to receive(:send_email).and_return(nil)
      notification.notify(search)
      expect(notification.current_state).to be_kind_of MailHandler::Receiving::Notification::Delay
    end

    it 'received' do
      allow(search).to receive(:started_at) { Time.now - 2 }
      allow(search).to receive(:result).and_return(true)
      allow(notification).to receive(:send_email).and_return(nil)
      notification.notify(search)
      expect(notification.current_state).to be_kind_of MailHandler::Receiving::Notification::Received
    end

    it 'max delayed' do
      allow(search).to receive(:started_at) { Time.now - 10 }
      allow(search).to receive(:result).and_return(false)
      allow(notification).to receive(:send_email).and_return(nil)
      notification.notify(search)
      expect(notification.current_state).to be_kind_of MailHandler::Receiving::Notification::MaxDelay
    end
  end
end
