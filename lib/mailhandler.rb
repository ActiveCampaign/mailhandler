# frozen_string_literal: true

require_relative 'mailhandler/sender'
require_relative 'mailhandler/receiver'

require_relative 'mailhandler/receiving/notification/email'
require_relative 'mailhandler/receiving/notification/console'
require_relative 'mailhandler/errors'

# Main MailHandler class, for creating sender and receiver objects.
# Sender objects for sending emails, receiver objects for searching and receiving emails.
module MailHandler
  module_function

  # sending accessor
  # @return [Object] - sender for sending emails
  #
  # Create a new sender by using code block:
  #
  # MailHandler.sender(:smtp) do |dispatcher|
  #     dispatcher.address = address
  #     dispatcher.port = port
  #     dispatcher.domain = domain
  #     dispatcher.username = username
  #     dispatcher.password = password
  #     dispatcher.use_ssl = use_ssl
  # end
  #
  # or by passing a settings hash:
  #
  # MailHandler.sender(:smtp, {address: 'example.com', port: 25})
  #
  # or by combining blocks and settings hash.
  #
  def sender(type = :postmark_api, settings = {})
    handler = Handler.new
    handler.init_sender(type, settings)
    yield(handler.sender.dispatcher) if block_given?

    handler.sender
  end

  # receiving accessor
  # @return [Object] - receiver for searching emails
  #
  # Create a new receiver by using code block:
  #
  # address = 'imap.example.com'
  # port = 993
  # username = 'john'
  # password = 'xxxxxxxxxxxxxx'
  # use_ssl = true
  #
  # email_receiver = MailHandler.receiver(:imap) do |checker|
  #   checker.address = address
  #   checker.port = port
  #   checker.username = username
  #   checker.password = password
  #   checker.use_ssl  =  use_ssl
  # end
  #
  # or by passing a settings hash:
  #
  # email_receiver = MailHandler.receiver(:imap, {address: 'example.com', port: 993})
  #
  # or by combining blocks and settings hash.
  #
  def receiver(type = :folder, settings = {})
    handler = Handler.new
    handler.init_receiver(type, settings)
    yield(handler.receiver.checker) if block_given?
    handler.receiver
  end

  # Holder for receiving and sending handlers
  #
  # @param [Receiving::Class] receiver
  # @param [Sending::Class] sender
  def handler(receiver, sender)
    handler = Handler.new
    handler.handler(receiver, sender)
  end

  # main handler class for creating sender, receiver handlers
  class Handler
    attr_accessor :sender,
                  :receiver

    def init_sender(type = :postmark_api, settings = {})
      verify_type(type, SENDER_TYPES)
      @sender = MailHandler::Sender.new(SENDER_TYPES[type].new)

      settings.each do |setting_name, setting_value|
        if @sender.dispatcher.respond_to?(setting_name)
          @sender.dispatcher.instance_variable_set("@#{setting_name}", setting_value)
        end
      end

      @sender
    end

    def init_receiver(type = :folder, settings = {})
      verify_type(type, CHECKER_TYPES)
      receiver = MailHandler::Receiver.new(CHECKER_TYPES[type].new)

      settings.each do |setting_name, setting_value|
        if receiver.checker.respond_to?(setting_name)
          receiver.checker.instance_variable_set("@#{setting_name}", setting_value)
        end
      end

      add_receiving_notifications(receiver, settings[:notifications])
      @receiver = receiver
    end

    def handler(sender, receiver)
      handler = new
      handler.sender = sender
      handler.receiver = receiver
      handler
    end

    private

    # Add notifications, in case email receiving is delayed.
    # When email is delayed, email notification can be sent or console status update.
    #
    # @param [Receiving::Object] receiver
    # @param [Array<Receiving::Notification::Class>] notifications
    def add_receiving_notifications(receiver, notifications)
      return if notifications.nil?
      return unless (notifications - NOTIFICATION_TYPES.keys).empty?

      notifications.each { |n| receiver.add_observer(NOTIFICATION_TYPES[n].new) }
    end

    def verify_type(type, types)
      raise MailHandler::TypeError, "Unknown type - #{type}, possible options: #{types.keys}." unless types.key?(type)
    end

    CHECKER_TYPES = {
      folder: Receiving::FolderChecker,
      imap: Receiving::IMAPChecker
    }.freeze

    SENDER_TYPES = {
      postmark_api: Sending::PostmarkAPISender,
      postmark_batch_api: Sending::PostmarkBatchAPISender,
      smtp: Sending::SMTPSender
    }.freeze

    NOTIFICATION_TYPES = {
      console: Receiving::Notification::Console,
      email: Receiving::Notification::Email
    }.freeze
  end
end
