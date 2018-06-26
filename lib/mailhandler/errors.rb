module MailHandler
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
