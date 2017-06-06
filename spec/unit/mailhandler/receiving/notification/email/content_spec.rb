require 'spec_helper'

describe MailHandler::Receiving::Notification::EmailContent do

  subject { MailHandler::Receiving::Notification::EmailContent.new }

  let(:to) { 'john@example.com' }
  let(:from) { 'igor@example.com' }
  let(:options) {{ :test => 'test' } }

  context '.email_received' do

    it 'create email' do

      expect(subject.retrieve(:received, options, 60, from, to)).to be_kind_of Mail::Message

    end

    context 'email content' do

      it 'sender' do

        expect(subject.retrieve(:received, options, 60, from, to)[:from].to_s).to eq from

      end

      it 'single recipient' do

        expect(subject.retrieve(:received, options, 60, from, to)[:to].to_s).to eq to

      end

      it 'multiple recipients' do

        to = 'john1@example.com, john2@example.com'
        expect(subject.retrieve(:received, options, 60, from, to)[:to].to_s).to eq to

      end

      it 'subject - 1 minute delay' do

        expect(subject.retrieve(:received, options, 60, from, to).subject).to eq "Received - delay was 1.0 minutes"

      end

      it 'subject - 1.5 minute delay' do

        expect(subject.retrieve(:received, options, 90, from, to).subject).to eq "Received - delay was 1.5 minutes"

      end

      it 'body' do

        expect(subject.retrieve(:received, options, 90, from, to).body.to_s).
            to eq "Received - delay was 1.5 minutes - search by #{options}"

      end

    end

  end

  context '.email_delayed' do

    it 'sender' do

      expect(subject.retrieve(:delayed, options, 60, from, to)[:from].to_s).to eq from

    end

    it 'single recipient' do

      expect(subject.retrieve(:delayed, options, 60, from, to)[:to].to_s).to eq to

    end

    it 'multiple recipients' do

      to = 'john1@example.com, john2@example.com'
      expect(subject.retrieve(:delayed, options, 60, from, to)[:to].to_s).to eq to

    end

    it 'subject - 1 minute delay' do

      expect(subject.retrieve(:delayed, options, 60, from, to).subject).to eq "Over 1.0 minutes delay"

    end

    it 'subject - 1.5 minute delay' do

      expect(subject.retrieve(:delayed, options, 90, from, to).subject).to eq "Over 1.5 minutes delay"

    end

    it 'body' do

      expect(subject.retrieve(:delayed, options, 90, from, to).body.to_s).
          to eq "Over 1.5 minutes delay - search by #{options}"

    end

  end

end