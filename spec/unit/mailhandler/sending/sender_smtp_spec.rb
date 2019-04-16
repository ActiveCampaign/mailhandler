require 'spec_helper'

describe MailHandler::Sending::SMTPSender do
  subject(:smtp_sender) { described_class }

  context '.send' do
    context 'invalid' do
      it 'incorrect mail type' do
        sender = smtp_sender.new
        expect { sender.send('Test') }.to raise_error MailHandler::TypeError
      end
    end
  end

  context '.new' do
    context 'smtp timeouts' do
      it 'open' do
        sender = smtp_sender.new
        expect(sender.open_timeout).to be > 0
      end

      it 'read' do
        sender = smtp_sender.new
        expect(sender.read_timeout).to be > 0
      end
    end

    it 'save response' do
      expect(smtp_sender.new.save_response).to be false
    end

    it 'use ssl' do
      expect(smtp_sender.new.use_ssl).to be false
    end

    it 'authentication' do
      expect(smtp_sender.new.authentication).to eq 'plain'
    end
  end
end
