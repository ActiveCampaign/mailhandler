require_relative '../errors'

module MailHandler
  module Sending
    class Sender
      attr_reader :type

      def send(_email)
        raise MailHandler::InterfaceError, 'Send interface not implemented.'
      end

      protected

      def verify_email(email)
        raise MailHandler::TypeError, "Invalid type error, only #{allowed_email_type} object type for sending allowed." unless email.is_a? allowed_email_type
      end

      private

      def allowed_email_type
        Mail::Message
      end
    end
  end
end
