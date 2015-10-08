require 'spec_helper'

describe MailHandler::Sender do

  subject { MailHandler::Sender }

  let(:send_duration) { 3 }
  let(:dispatcher) {
    dispatcher = double('Dispatcher')

    allow(dispatcher).to receive(:send) { sleep send_duration ; 'Sent' }
    dispatcher

  }
  let(:mail) {

    Mail.new do
      from "sheldon@bigbangtheory.com"
      to "lenard@bigbangtheory.com"
      subject "Hello!"
      body "Hello Sheldon!"
    end

  }

  it '.sending' do

    expect(subject.new(dispatcher)).not_to be nil

  end

  it '.sending init' do

    sender = subject.new(dispatcher)

    aggregate_failures "sending details" do
      expect(sender.sending.started_at).to be nil
      expect(sender.sending.finished_at).to be nil
      expect(sender.sending.duration).to be nil
      expect(sender.sending.response).to be nil
      expect(sender.sending.email).to be nil
    end

  end

  it '.send_email' do

    sender = subject.new(dispatcher)
    sender.send_email(mail)

    aggregate_failures "sending details" do
      expect(sender.sending.started_at).to be_within(1).of(Time.now - send_duration)
      expect(sender.sending.finished_at).to be_within(1).of(Time.now)
      expect(sender.sending.duration).to be_within(0.5).of(send_duration)
      expect(sender.sending.response).to eq 'Sent'
      expect(sender.sending.email).to be mail
    end

  end

end