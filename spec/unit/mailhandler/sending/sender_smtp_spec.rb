require 'spec_helper'

describe MailHandler::Sending::SMTPSender do
  subject { MailHandler::Sending::SMTPSender }

  context '.send' do
    context 'invalid' do
      it 'incorrect mail type' do
        sender = subject.new
        expect { sender.send('Test') }.to raise_error MailHandler::TypeError
      end
    end
  end

  context '.new' do
    context 'smtp timeouts' do
      it 'open' do
        sender = subject.new
        expect(sender.open_timeout).to be > 0
      end

      it 'read' do
        sender = subject.new
        expect(sender.read_timeout).to be > 0
      end
    end

    it 'save response' do
      expect(subject.new.save_response).to be false
    end

    it 'use ssl' do
      expect(subject.new.use_ssl).to be false
    end

    it 'authentication' do
      expect(subject.new.authentication).to eq 'plain'
    end
  end
end
