require_relative 'api.rb'

module MailHandler

  module Sending

    class PostmarkBatchAPISender < PostmarkAPISender

      def send(emails)

        verify_email(emails)
        client = setup_sending_client
        client.deliver_messages(emails)

      end

      protected

      def verify_email(emails)

        raise StandardError, "Invalid type error, only Array of Mail::Message object types for sending allowed" unless emails.is_a?(Array) && emails.all? { |e| e.is_a? Mail::Message }

      end

    end

  end

end
