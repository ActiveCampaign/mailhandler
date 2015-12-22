require 'spec_helper'

describe MailHandler::Sending::SMTPSender do

  subject { MailHandler::Sending::SMTPSender }

  context '.send' do

    context 'invalid' do

      it 'incorrect mail type' do

        sender = subject.new
        expect { sender.send('Test') }.to raise_error MailHandler::TypeError

      end

      it 'incorrect auth' do

        sender = subject.new
        mail = Mail.new do

          from 'igor@example.com'
          subject 'example'
          body 'example'
          to 'igor@example'

        end

        expect { sender.send(mail) }.to raise_error Errno::ECONNREFUSED

      end

    end

  end

end