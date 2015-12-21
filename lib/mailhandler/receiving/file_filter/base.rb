require 'fileutils'

# Base filtering class, which is used for reading list of all files based on passed pattern.
# Patterns to be used can be checked here: http://ruby-doc.org/core-1.9.3/Dir.html
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

    protected

    def read_email(content)

      Mail.read_from_string(content)

    end

  end

end

