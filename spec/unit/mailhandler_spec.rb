require 'spec_helper'

describe MailHandler::Handler do

  subject { MailHandler::Handler }

  context 'receiver' do

    it 'create - invalid type' do

      expect { subject.receiver(:test) }.
          to raise_error(StandardError, 'Unknown type - test, possible options: [:folder, :imap]')

    end

    it 'create - folder' do

      expect(subject.receiver(:folder)).to be_kind_of MailHandler::Receiver

    end

    it 'create - imap' do

      expect(subject.receiver(:imap)).to be_kind_of MailHandler::Receiver

    end

  end

  context 'sender' do

    it 'create - invalid type' do

      expect { subject.sender(:test) }.
          to raise_error(StandardError, 'Unknown type - test, possible options: [:postmark_api, :postmark_batch_api, :smtp]')

    end

    it 'create - postmark api' do

      expect(subject.sender(:postmark_api)).to be_kind_of MailHandler::Sender

    end

    it 'create - postmark batch api' do

      expect(subject.sender(:postmark_batch_api)).to be_kind_of MailHandler::Sender

    end

    it 'create - smtp' do

      expect(subject.sender(:smtp)).to be_kind_of MailHandler::Sender

    end

  end

end