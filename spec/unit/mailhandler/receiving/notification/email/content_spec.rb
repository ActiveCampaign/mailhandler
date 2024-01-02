# frozen_string_literal: true

require 'spec_helper'

describe MailHandler::Receiving::Notification::EmailContent do
  subject(:notification_email_content) { described_class.new }

  let(:to) { 'john@example.com' }
  let(:from) { 'igor@example.com' }
  let(:options) { { test: 'test' } }

  describe '.email_received' do
    it 'create email' do
      expect(notification_email_content.retrieve(:received, options, 60, from, to)).to be_a Mail::Message
    end

    context 'email content' do
      it 'sender' do
        expect(notification_email_content.retrieve(:received, options, 60, from, to)[:from].to_s).to eq from
      end

      it 'single recipient' do
        expect(notification_email_content.retrieve(:received, options, 60, from, to)[:to].to_s).to eq to
      end

      it 'multiple recipients' do
        to = 'john1@example.com, john2@example.com'
        expect(notification_email_content.retrieve(:received, options, 60, from, to)[:to].to_s).to eq to
      end

      it 'notification_email_content - 1 minute delay' do
        expect(notification_email_content.retrieve(:received, options, 60, from, to).subject)
          .to eq 'Received - delay was 1.0 minutes'
      end

      it 'notification_email_content - 1.5 minute delay' do
        expect(notification_email_content.retrieve(:received, options, 90, from, to).subject)
          .to eq 'Received - delay was 1.5 minutes'
      end

      it 'body' do
        expect(notification_email_content.retrieve(:received, options, 90, from, to).body.to_s)
          .to eq "Received - delay was 1.5 minutes - search by #{options}"
      end
    end
  end

  describe '.email_delayed' do
    it 'sender' do
      expect(notification_email_content.retrieve(:delayed, options, 60, from, to)[:from].to_s).to eq from
    end

    it 'single recipient' do
      expect(notification_email_content.retrieve(:delayed, options, 60, from, to)[:to].to_s).to eq to
    end

    it 'multiple recipients' do
      to = 'john1@example.com, john2@example.com'
      expect(notification_email_content.retrieve(:delayed, options, 60, from, to)[:to].to_s).to eq to
    end

    it 'notification_email_content - 1 minute delay' do
      expect(notification_email_content.retrieve(:delayed, options, 60, from, to).subject)
        .to eq 'Over 1.0 minutes delay'
    end

    it 'notification_email_content - 1.5 minute delay' do
      expect(notification_email_content.retrieve(:delayed, options, 90, from, to).subject)
        .to eq 'Over 1.5 minutes delay'
    end

    it 'body' do
      expect(notification_email_content.retrieve(:delayed, options, 90, from, to).body.to_s)
        .to eq "Over 1.5 minutes delay - search by #{options}"
    end
  end
end
