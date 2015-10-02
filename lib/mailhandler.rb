require_relative 'mailhandler/sender'
require_relative 'mailhandler/receiver'

require_relative 'mailhandler/receiving/notification/email'
require_relative 'mailhandler/receiving/notification/console'

module MailHandler

  class Handler

    attr_accessor :sender,
                  :receiver

    def self.sender(type = :postmark_api)

      verify_type(type, SENDER_TYPES)
      sender = MailHandler::Sender.new(SENDER_TYPES[type].new)
      yield(sender.dispatcher) if block_given?

      sender

    end


    def self.receiver(type = :folder, notifications = [])

      verify_type(type, CHECKER_TYPES)
      receiver = MailHandler::Receiver.new(CHECKER_TYPES[type].new)
      add_receiving_notifications(receiver, notifications)

      yield(receiver.checker) if block_given?

      receiver

    end

    def self.handler(sender, receiver)

      handler = new
      handler.sender = sender
      handler.receiver = receiver
      handler

    end

    private

    def self.add_receiving_notifications(receiver, notifications)

      if (notifications - NOTIFICATION_TYPES.keys).empty?

        notifications.each { |n| receiver.add_observer(NOTIFICATION_TYPES[n].new) }

      end

    end

    def self.verify_type(type, types)

      raise StandardError, "Unknown type - #{type}, possible options: #{types.keys}" unless types.keys.include? type

    end

    CHECKER_TYPES = {

        :folder => Receiving::FolderChecker,
        :imap => Receiving::IMAPChecker

    }

    SENDER_TYPES = {

        :postmark_api => Sending::PostmarkAPISender,
        :postmark_batch_api => Sending::PostmarkBatchAPISender,
        :smtp => Sending::SMTPSender

    }

    NOTIFICATION_TYPES = {

        :console => Receiving::Notification::Console,
        :email => Receiving::Notification::Email

    }

  end

end



