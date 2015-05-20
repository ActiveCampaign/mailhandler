require_relative 'email_handling/receiver'

module EmailHandling

  class Handler

    attr_accessor :receiver

    CHECKER_TYPES = {

        :folder => Receiving::FolderChecker,
        :imap => Receiving::IMAPChecker

    }

    def self.receiver(type = :folder)

      raise StandardError, "Unknown receiving type - #{type}, possible options: #{CHECKER_TYPES.keys}" unless CHECKER_TYPES.keys.include? type

      receiver = EmailHandling::Receiver.new(CHECKER_TYPES[type].new)
      yield(receiver.checker) if block_given?
      receiver

    end

  end

end


