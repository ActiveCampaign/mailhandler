require_relative 'email_handling/receiver'
require_relative 'email_handling/receiving/alerts/email'
require_relative 'email_handling/receiving/alerts/console'

# This module contains the main email handling class which allows verification that
# email is received.
#
# @example Email Handler initialization, when using folder to check email arrival.
#
# path = "/FolderToCheck"
#
# receive_handler = EmailHandling::Handler.receiver(:folder) do |checker|
#
#  checker.inbox_folder = path
#  checker.archive_folder = path + '/checked'
#
# end
#
# @example Email Handler initialization, when using email, imap protocol to check email arrival.
#
# receive_handler.find_email(:by_subject => "email subject", :by_recipient => {:to => "igor@example.com"}, :archive => true)
# receive_handler.search.result
# receive_handler.search.emails.each { |email| puts email }
#
# @see EmailHandling::Receiver to see details about class receiving handler and available methods.
#
#
# receive_handler = EmailHandling::Handler.receiver(:imap) do |checker|
#
#  checker.imap_details('imap.googlemail.com',993,'username','password', true)
#
# end
#
module EmailHandling

  class Handler

    attr_accessor :receiver

    CHECKER_TYPES = {

        :folder => Receiving::FolderChecker,
        :imap => Receiving::IMAPChecker

    }

    def self.receiver(type = :folder, default_alerts = [:console, :email])

      raise StandardError, "Unknown receiving type - #{type}, possible options: #{CHECKER_TYPES.keys}" unless CHECKER_TYPES.keys.include? type

      receiver = EmailHandling::Receiver.new(CHECKER_TYPES[type].new)
      yield(receiver.checker) if block_given?

      default_alerts.each { |alert| receiver.add_observer(ALERT_TYPES[alert].new(receiver)) } if (default_alerts - ALERT_TYPES.keys).empty?
      receiver

    end

    def self.handler(receiver)

      handler = new
      handler.receiver = receiver
      handler

    end

    private

    ALERT_TYPES = {

        :console => Receiving::Alert::Console,
        :email => Receiving::Alert::Email

    }

  end

end


