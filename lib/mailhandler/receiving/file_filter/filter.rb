require 'fileutils'

module Filter

  # Base filtering class, which is used for reading list of all files based on passed pattern.
  # Patterns to be used can be checked here: http://ruby-doc.org/core-1.9.3/Dir.html
  class Base

    def Base.sort(files)

      swapped = true
      j = 0

      while swapped do

        swapped = false
        j+=1

        (files.size - j).times do |i|

          if File.new(files[i]).ctime < File.new(files[i + 1]).ctime
            tmp = files[i]
            files[i] = files[i + 1]
            files[i + 1] = tmp
            swapped = true

          end

        end

      end

      files

    end

    def get(pattern)

      files = []
      Dir.glob(pattern).each { |file| files << File.absolute_path(file) }
      files

    end

    protected

    def read_email(content)

      Mail.read_from_string(content)

    end

  end

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