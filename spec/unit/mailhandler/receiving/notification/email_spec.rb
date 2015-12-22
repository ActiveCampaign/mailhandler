require 'spec_helper'

describe MailHandler::Receiving::Notification::Email do

  let(:search) { double('search') }
  let(:sender) { double('sender') }
  let(:notification) { MailHandler::Receiving::Notification::Email.new(sender, 'igor@example.com',1) }

  before(:each) do

    allow(sender).to receive(:send_email) { true }
    allow(search).to receive(:max_duration) { 5 }
    allow(search).to receive(:started_at) { Time.now }

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

    notification.notify(search)
    expect(notification.max_time_to_notify).to eq search.max_duration

  end

end