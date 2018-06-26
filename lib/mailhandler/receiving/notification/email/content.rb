require 'mail'

module MailHandler
  module Receiving
    module Notification
      class EmailContent
        # @param [Symbol] type - notification type
        # @param [Hash] options - search options used for searching for an email
        # @param [Int] delay - delay in seconds
        # @param [String] from - email address
        # @param [String] to - email address
        def retrieve(type, options, delay, from, to)
          mail = Mail.new
          mail.from = from
          mail.to = to
          delay = (delay.to_f / 60).round(2)

          case type

          when :received

            mail.subject = "Received - delay was #{delay} minutes"
            mail.body = "Received - delay was #{delay} minutes - search by #{options}"

          when :delayed

            mail.subject = "Over #{delay} minutes delay"
            mail.body = "Over #{delay} minutes delay - search by #{options}"

          else

            raise StandardError, "Incorrect type: #{type}"

          end

          mail
        end
      end
    end
  end
end
