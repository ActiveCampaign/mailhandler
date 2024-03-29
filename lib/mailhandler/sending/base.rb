# frozen_string_literal: true

require 'mail'
require_relative '../errors'

module MailHandler
  module Sending
    # email sending handler class
    class Sender
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def send(_email)
        raise MailHandler::InterfaceError, 'Send interface not implemented.'
      end

      def valid_response?(_response)
        raise MailHandler::InterfaceError, 'Method not implemented.'
      end

      protected

      def verify_email(email)
        return if email.is_a?(allowed_email_type)

        raise MailHandler::TypeError, "Invalid type error, only #{allowed_email_type} object type for sending allowed."
      end

      private

      def allowed_email_type
        Mail::Message
      end
    end
  end
end
