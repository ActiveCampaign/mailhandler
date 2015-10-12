# encoding: utf-8
require 'net/imap'
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

      def initialize

        @type = :smtp
        @authentication = 'plain'
        @use_ssl = false

      end

      def send(email)

        verify_email(email)
        email = configure_sending(email)

        response = nil

        begin

          response = email.deliver

        rescue Exception => e

          response = e.to_s

        end

        response

      end

      private

      def configure_sending(email)

        options = {

            :address => address,
            :port => port,
            :domain => domain,
            :user_name => username,
            :password => password,
            :authentication => @authentication,
            :enable_starttls_auto => @use_ssl

        }

        email.delivery_method :smtp, options
        email

      end

    end

  end

end
