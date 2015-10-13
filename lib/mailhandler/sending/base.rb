module MailHandler

  module Sending

    class Sender

      attr_reader :type

      protected

      def verify_email(email)

        raise StandardError, "Invalid type error, only #{Mail.new.class} object type for sending allowed" unless email.is_a? Mail.new.class

      end

    end

  end

end