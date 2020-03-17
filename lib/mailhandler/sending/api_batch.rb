# frozen_string_literal: true

require_relative 'api.rb'
require_relative '../errors'

module MailHandler
  module Sending
    # sending batch email by Postmark API
    class PostmarkBatchAPISender < PostmarkAPISender
      def initialize(api_token = nil)
        super(api_token)
      end

      def send(emails)
        verify_email(emails)
        init_client
        client.deliver_messages(emails)
      end

      def valid_response?(responses)
        responses.map { |response| super(response) }.all?(true)
      end

      protected

      def verify_email(emails)
        return if emails.is_a?(Array) && emails.all? { |e| e.is_a? allowed_email_type }

        raise MailHandler::TypeError, 'Invalid type error, only Array of Mail::Message object types for sending allowed'
      end
    end
  end
end
