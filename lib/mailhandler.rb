require_relative 'mailhandler/sender'
require_relative 'mailhandler/receiver'

require_relative 'mailhandler/receiving/notification/email'
require_relative 'mailhandler/receiving/notification/console'

# This module contains the main email handling class which has two main email handlers, sender and receiver.
# Received allows verification that email is received.
#
# @example Receiver example - Email Handler initialization, when using folder to check email arrival.
# @see MailHandler::Receiver to see details about class receiving handler and available methods.
#
# path = "/FolderToCheck"
#
# receive_handler = MailHandler::Handler.receiver(:folder) do |checker|
#
#  checker.inbox_folder = path
#  checker.archive_folder = path + '/checked'
#
# end
#
# @example Email Handler initialization, when using email, imap protocol to check email arrival.
#
# receive_handler = MailHandler::Handler.receiver(:imap) do |checker|
#
#  checker.imap_details('imap.googlemail.com',993,'username','password', true)
#
# end
#
# Once handler is initialized you can find emails like this:
#
# receive_handler.find_email(:by_subject => "email subject", :by_recipient => {:to => "igor@example.com"}, :archive => true)
# receive_handler.search.result
# receive_handler.search.emails.each { |email| puts email }
#
# Sending email - sending email handler is used to send emails by Postmark API or by SMTP.
# @see MailHandler::Sender to see details about class sending handler and available methods.
#
# @example Sender example - initialisation
#
# sending_handler = MailHandler::Handler.sender(:postmark_api) do |dispatcher|
#
#  dispatcher.host = 'api.postmarkapp.com'
#  dispatcher.api_token = 'YOUR_TOKEN'
#
# end
#
# mail = Mail.new do
#   from 'igor@example.com'
#   to 'igor@example.com'
#   body 'test'
# end
#
# sending_handler.send_email(mail)
#
# @example Sending email in batches
#
# sending_handler = MailHandler::Handler.sender(:postmark_batch_api) do |dispatcher|
#
#  dispatcher.host = 'api.postmarkapp.com'
#  dispatcher.api_token = 'YOUR_TOKEN'
#
# end
#
# sending_handler.send_email([mail,mail])
#
# @example Sending email by SMTP
# sending_handler = MailHandler::Handler.sender(:smtp) do |dispatcher|
#
#  dispatcher.address = 'smtp.gmail.com'
#  dispatcher.port = 587
#  dispatcher.domain = 'smtp.gmail.com'
#  dispatcher.username = 'example@gmail.com'
#  dispatcher.password = 'password'
#  dispatcher.use_ssl = true
#
# end
#
# sending_handler.send_email(mail)
#


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



