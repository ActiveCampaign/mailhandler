require 'fileutils'

module Filter

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

  end

  class ByFilename < Base

    def get(pattern)

      super(pattern)

    end

  end

  class ByContent < Base

    def initialize(content)

      @content = content

    end

    def get(pattern)

      files = super(pattern)

      matched_files = []

      files.each do |file|

        begin

          content = File.read(file)
          matched_files << file if content.include? @content

        rescue

          # skip file reading if file is not there anymore

        end

      end

      matched_files

    end

  end

  class ByDate < Base

    def initialize(date)

      @date = date

    end

    def get(pattern)

      files = super(pattern)
      files.select { |filename|

        file = nil
        begin

          file = File.new(filename)

        rescue

          # skip file reading if file is not there anymore

        end

        file.ctime > @date if (file != nil)

      }

    end

  end

  module Email

    class ByRecipient < Base

      def initialize(recipient)

        @recipient = recipient

      end

      def get(pattern)

        files = super(pattern)

        matched_files = []

        files.each do |file|

          begin

            content = File.read(file)

            email = Mail.read_from_string(content)
            matched_files << file if email[@recipient.keys.first].to_s.include? @recipient.values.first

          rescue

            # skip file reading if file is not there anymore

          end

        end

        matched_files

      end

    end

  end

end