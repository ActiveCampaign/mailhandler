require 'spec_helper'

describe MailHandler::Handler do
  subject { MailHandler::Handler.new }

  context 'receiver' do
    it 'create - invalid type' do
      expect { subject.init_receiver(:test) }
        .to raise_error(MailHandler::TypeError, 'Unknown type - test, possible options: [:folder, :imap].')
    end

    it 'create - folder' do
      expect(subject.init_receiver(:folder)).to be_kind_of MailHandler::Receiver
    end

    it 'create - imap' do
      expect(subject.init_receiver(:imap)).to be_kind_of MailHandler::Receiver
    end
  end

  context 'init_sender' do
    it 'create - invalid type' do
      expect { subject.init_sender(:test) }
        .to raise_error(MailHandler::TypeError, 'Unknown type - test, possible options: [:postmark_api, :postmark_batch_api, :smtp].')
    end

    it 'create - postmark api' do
      expect(subject.init_sender(:postmark_api)).to be_kind_of MailHandler::Sender
    end

    it 'create - postmark batch api' do
      expect(subject.init_sender(:postmark_batch_api)).to be_kind_of MailHandler::Sender
    end

    context 'smtp' do
      it 'create - smtp' do
        expect(subject.init_sender(:smtp)).to be_kind_of MailHandler::Sender
      end

      context 'set delivery methods' do
        it 'save response' do
          sender = MailHandler.sender(:smtp) do |dispatcher|
            dispatcher.save_response = true
          end

          expect(sender.dispatcher.save_response).to be true
        end

        it 'open timeout' do
          sender = MailHandler.sender(:smtp) do |dispatcher|
            dispatcher.open_timeout = 30
          end

          expect(sender.dispatcher.open_timeout).to be 30
        end

        it 'read timeout' do
          sender = MailHandler.sender(:smtp) do |dispatcher|
            dispatcher.read_timeout = 30
          end

          expect(sender.dispatcher.read_timeout).to be 30
        end
      end
    end
  end
end
