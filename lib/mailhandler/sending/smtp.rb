# frozen_string_literal: true

require_relative 'base'

module MailHandler
  module Sending
    # class which describes methods to send and receive emails
    class SMTPSender < Sender
      attr_accessor :address,
                    :port,
                    :domain,
                    :username,
                    :password,
                    :authentication,
                    :use_ssl

      attr_accessor :open_timeout,
                    :read_timeout,
                    :save_response

      def initialize
        @type = :smtp
        @authentication = 'plain'
        @use_ssl = false
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
        response = init_net_smtp.start(domain, username, password, authentication) do |smtp|
          smtp.send_message(text_email, smtp_from, smtp_to)
        end

        save_response ? response : nil
      end

      private

      def init_net_smtp
        sending = Net::SMTP.new(address, port)
        sending.read_timeout = read_timeout
        sending.open_timeout = open_timeout
        sending.enable_starttls_auto if use_ssl
        sending
      end

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

          return_response: save_response,
          open_timeout: open_timeout,
          read_timeout: read_timeout
        }
      end
    end
  end
end
