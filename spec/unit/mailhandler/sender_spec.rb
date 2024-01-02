# frozen_string_literal: true

require 'spec_helper'

describe MailHandler::Sender do
  subject { described_class }

  let(:send_duration) { 3 }
  let(:dispatcher) do
    dispatcher = instance_double(MailHandler::Sending::Sender)

    allow(dispatcher).to receive(:send) do
      sleep send_duration
      'Sent'
    end

    dispatcher
  end
  let(:mail) do
    Mail.new(
      {
        from: 'sheldon@bigbangtheory.com',
        to: 'lenard@bigbangtheory.com',
        subject: 'Hello',
        body: 'Hello Sheldon!'
      }
    )
  end

  let(:sender) { subject.new(dispatcher) }

  it 'create' do
    expect(sender).not_to be_nil
  end

  it 'init details' do
    aggregate_failures 'sending details' do
      expect(sender.sending.started_at).to be_nil
      expect(sender.sending.finished_at).to be_nil
      expect(sender.sending.duration).to be_nil
      expect(sender.sending.response).to be_nil
      expect(sender.sending.email).to be_nil
    end
  end

  it '.send_email' do
    sender.send_email(mail)

    aggregate_failures 'sending details' do
      expect(sender.sending.started_at).to be_within(1).of(Time.now - send_duration)
      expect(sender.sending.finished_at).to be_within(1).of(Time.now)
      expect(sender.sending.duration).to be_within(0.5).of(send_duration)
      expect(sender.sending.response).to eq 'Sent'
      expect(sender.sending.email).to be mail
    end
  end
end
