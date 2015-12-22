require 'mail'

module MailHandler

  module Receiving

    module Notification

      class EmailContent

        # @param [Hash] options - search options used for searching for an email
        # @param [Int] delay - delay in seconds
        # @param [String] from - email address
        # @param [String] to - email address
        def self.email_received(options, delay, from, to)

          Mail.new do

            from from
            subject "Received - delay was #{(delay.to_f/60).round(2)} minutes"
            body "Received - delay was #{(delay.to_f/60).round(2)} minutes - search by #{options}"
            to to

          end

        end

        # @param [Hash] options - search options used for searching for an email
        # @param [Int] delay - delay in seconds
        # @param [String] from - email address
        # @param [String] to - email address
        def self.email_delayed(options, delay, from, to)

          Mail.new do

            from from
            subject "Over #{(delay.to_f/60).round(2)} minutes delay"
            body "Over #{(delay.to_f/60).round(2)} minutes delay - search by #{options}"
            to to

          end

        end

      end

    end

  end

end
