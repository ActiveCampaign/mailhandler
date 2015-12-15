require_relative 'mailhandler/sender'
require_relative 'mailhandler/receiver'

require_relative 'mailhandler/receiving/notification/email'
require_relative 'mailhandler/receiving/notification/console'
require_relative 'mailhandler/errors'

# Main MailHandler class, that allows you to create sender and receiver objects.
# Sender objects for sending emails, receiver objects for receiving emails from certain mailboxes.

module MailHandler

  extend self

  # sending accessor
  def sender(type = :postmark_api)

    handler = Handler.new
    handler.init_sender(type)
    yield(handler.sender.dispatcher) if block_given?

    handler.sender

  end

  # receiving accessor
  def receiver(type = :folder, notifications = [])

    handler = Handler.new
    handler.init_receiver(type, notifications)
    yield(handler.receiver.checker) if block_given?

    handler.receiver

  end

  # handling accessor
  def handler(receiver, sender)

    handler = Handler.new
    handler.handler(receiver, sender)

  end

  # main handler class for creating sender, receiver handlers
  class Handler

    attr_accessor :sender,
                  :receiver

    def init_sender(type = :postmark_api)

      verify_type(type, SENDER_TYPES)
      @sender = MailHandler::Sender.new(SENDER_TYPES[type].new)

    end


    def init_receiver(type = :folder, notifications = [])

      verify_type(type, CHECKER_TYPES)
      @receiver = MailHandler::Receiver.new(CHECKER_TYPES[type].new)
      add_receiving_notifications(@receiver, notifications)
      @receiver

    end

    def handler(sender, receiver)

      handler = new
      handler.sender = sender
      handler.receiver = receiver
      handler

    end

    private

    # method for adding custom notifications, in case email delivery is delayed.
    def add_receiving_notifications(receiver, notifications)

      if (notifications - NOTIFICATION_TYPES.keys).empty?

        notifications.each { |n| receiver.add_observer(NOTIFICATION_TYPES[n].new) }

      end

    end

    def verify_type(type, types)

      raise MailHandler::TypeError, "Unknown type - #{type}, possible options: #{types.keys}" unless types.keys.include? type

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



