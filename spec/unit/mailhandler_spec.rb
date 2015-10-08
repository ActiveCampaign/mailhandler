require 'spec_helper'

describe MailHandler::Handler do

  subject { MailHandler::Handler }

  context 'receiver' do

    let(:receiver_folder) {

      subject.receiver(:folder)

    }

    it 'invalid type' do

      expect{subject.receiver(:test)}.
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

      expect{subject.sender(:test)}.
          to raise_error(StandardError, 'Unknown type - test, possible options: [:postmark_api, :postmark_batch_api, :smtp]')

    end

    it 'create sender - postmark api' do

      expect(subject.sender(:postmark_api)).to match MailHandler::Sender

    end

    it 'create sender - postmark batch api' do

      expect(subject.sender(:postmark_batch_api)).to match MailHandler::Sender

    end

    it 'create sender - smtp' do

      expect(subject.sender(:smtp)).to match MailHandler::Sender

    end

  end

end