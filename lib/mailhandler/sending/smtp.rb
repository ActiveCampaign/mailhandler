# frozen_string_literal: true

require_relative 'base'
require_relative '../extensions/mail/smtp'

module MailHandler
  module Sending
    # class which describes methods to send and receive emails
    class SMTPSender < Sender
      attr_accessor :address, :port, :domain, :username, :password, :authentication, :use_ssl, :openssl_verify_mode,
                    :open_timeout, :read_timeout, :save_response

      def initialize
        super(:smtp)

        @authentication = 'plain'
        @use_ssl = true
        @save_response = true

        @open_timeout = 60
        @read_timeout = 60
      end

      def send(email)
        verify_email(email)
        email = configure_sending(email)
        save_response ? email.deliver! : email.deliver
      end

      def send_raw_email(text_email, smtp_from, smtp_to)
        # use same settings as when sending mail created with Mail gem
        response = Mail::SMTP.new(delivery_options).deliver_raw!(text_email, smtp_from, smtp_to)
        save_response ? response : nil
      end

      def can_authenticate?
        method_name = 'start_smtp_session' # Mail::SMTP private method
        configure_sending(Mail.new).delivery_method.send(method_name)
        true
      rescue Net::SMTPAuthenticationError
        false
      end

      def valid_response?(response)
        response.string.to_s.downcase.include?('250 2.0.0 ok')
      end

      def timeout=(value)
        @read_timeout = value
        @open_timeout = value
      end

      private

      def configure_sending(email)
        email.delivery_method :smtp, delivery_options
        email
      end

      def delivery_options
        {
          address: address,
          port: port,
          domain: domain,
          user_name: username,
          password: password,
          authentication: @authentication,
          enable_starttls_auto: @use_ssl,
          openssl_verify_mode: @openssl_verify_mode,

          return_response: save_response,
          open_timeout: open_timeout,
          read_timeout: read_timeout
        }
      end
    end
  end
end
