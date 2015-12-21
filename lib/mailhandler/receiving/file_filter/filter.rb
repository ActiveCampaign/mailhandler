require_relative 'base.rb'

# Implementations of base filtering, which will allow further filtering the list of files based on email content.
module Filter

  class ByFilename < Base

    def get(pattern)

      super(pattern)

    end

  end

  class ContentBase < Base

    def initialize(content)

      @content = content.to_s

    end

    protected

    def filter_files(files)

      files.select do |file|

        begin

          file_match_filter?(file)

        rescue

          # return false if error occurred or content was not found
          false

        end

      end

    end

    def file_match_filter?(file)

      raise StandardError, 'Not implemented'

    end

  end

  class BySubject < ContentBase

    def initialize(content)

      super(content)

    end

    def get(pattern)

      files = super(pattern)
      filter_files(files)

    end

    private

    def file_match_filter?(file)

      read_email(File.read(file)).subject.include? @content

    end

  end

  class ByContent < ContentBase

    def initialize(content)

      super(content)

    end

    def get(pattern)

      files = super(pattern)
      filter_files(files)

    end

    private

    def file_match_filter?(file)

      File.read(file).include? @content

    end

  end

  class ByDate < ContentBase

    def initialize(date)

      @date = date

    end

    def get(pattern)

      files = super(pattern)
      filter_files(files)

    end

    private

    def file_match_filter?(file)

      file = File.new(file)
      if file != nil

        file.ctime > @date

      else

        false

      end

    end

  end

  module Email

    class ByRecipient < ContentBase

      def initialize(recipient)

        @recipient = recipient

      end

      def get(pattern)

        files = super(pattern)
        filter_files(files)

      end

      private

      def file_match_filter?(file)

        email = read_email(File.read(file))
        email[@recipient.keys.first].to_s.include? @recipient.values.first

      end

    end

  end

end