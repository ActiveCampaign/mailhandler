require 'spec_helper'

describe MailHandler::Handler do

  subject { MailHandler::Handler.new }

  context 'receiver' do

    it 'create - invalid type' do

      expect { subject.init_receiver(:test) }.
          to raise_error(MailHandler::TypeError, 'Unknown type - test, possible options: [:folder, :imap].')

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

      expect { subject.init_sender(:test) }.
          to raise_error(MailHandler::TypeError, 'Unknown type - test, possible options: [:postmark_api, :postmark_batch_api, :smtp].')

    end

    it 'create - postmark api' do

      expect(subject.init_sender(:postmark_api)).to be_kind_of MailHandler::Sender

    end

    it 'create - postmark batch api' do

      expect(subject.init_sender(:postmark_batch_api)).to be_kind_of MailHandler::Sender

    end

    it 'create - smtp' do

      expect(subject.init_sender(:smtp)).to be_kind_of MailHandler::Sender

    end

  end

end