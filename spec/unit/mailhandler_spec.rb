require 'spec_helper'

describe MailHandler do

  subject(:handler) { MailHandler::Handler }

  context 'receiver' do

    let(:receiver_folder) {

      handler.receiver(:folder)

    }

    it 'invalid type' do

      expect{handler.receiver(:test)}.
          to raise_error(StandardError, 'Unknown type - test, possible options: [:folder, :imap]')

    end

    context 'folder check' do

      it 'object type' do

        expect(receiver_folder).to match MailHandler::Receiver

      end

    end


  end

  context 'sender' do

    it 'invalid type' do

      expect{handler.sender(:test)}.
          to raise_error(StandardError, 'Unknown type - test, possible options: [:postmark_api, :postmark_batch_api, :smtp]')

    end

    it 'create sender - postmark api' do

      expect(handler.sender(:postmark_api)).to match MailHandler::Sender

    end

    it 'create sender - postmark batch api' do

      expect(handler.sender(:postmark_batch_api)).to match MailHandler::Sender

    end

    it 'create sender - smtp' do

      expect(handler.sender(:smtp)).to match MailHandler::Sender

    end

  end

end