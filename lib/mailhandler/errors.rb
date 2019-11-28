# frozen_string_literal: true

module MailHandler
  # base error
  class Error < StandardError
    def initialize(message = nil)
      super(message)
    end
  end

  class UnknownError        < Error; end
  class TypeError           < Error; end
  class FileError           < Error; end
  class InterfaceError      < Error; end
end
