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

end