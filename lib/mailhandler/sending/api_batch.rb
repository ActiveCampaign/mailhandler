require_relative 'api.rb'
require_relative '../errors'

module MailHandler

  module Sending

    class PostmarkBatchAPISender < PostmarkAPISender

      def initialize(api_token = nil)

        super(api_token)

      end

      def send(emails)

        verify_email(emails)
        client = setup_sending_client
        client.deliver_messages(emails)

      end

      protected

      def verify_email(emails)

        raise MailHandler::TypeError, "Invalid type error, only Array of Mail::Message object types for sending allowed" unless emails.is_a?(Array) && emails.all? { |e| e.is_a? allowed_email_type }

      end

    end

  end

end
