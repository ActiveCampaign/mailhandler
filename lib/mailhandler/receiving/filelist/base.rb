require 'fileutils'

# Base filtering class, which is used for reading list of all files based on passed pattern.
# Patterns to be used can be checked here: http://ruby-doc.org/core-1.9.3/Dir.html

module MailHandler

  module Receiving

    module FileHandling

      # if file exists, execute file operation, otherwise return default return value when it doesn't
      def access_file(file, default_return = false, &block)

        if File.exists? file

          begin

            block.call

          rescue => e

            raise e if File.exists? file
            default_return

          end

        else

          default_return

        end

      end

    end

    class FileList

      include FileHandling

      def get(pattern)

        Dir.glob(pattern)

      end

      def sort(files)

        swapped = true
        j = 0

        while swapped do

          swapped = false
          j+=1

          (files.size - j).times do |i|

            file1 = access_file(files[i], false) { File.new(files[i]).ctime }
            file2 = access_file(files[i+1], false) { File.new(files[i+1]).ctime }

            if file1 && file2 && file1 < file2
              tmp = files[i]
              files[i] = files[i + 1]
              files[i + 1] = tmp
              swapped = true

            end

          end

        end

        files

      end

    end

  end

end

=begin

TEST EXAMPLE

FileList.get('*.*')
FileList::Filter::ByEmailSubject.new(files,'subject').get
FileList::Filter::ByEmailContent.new(files,'content').get
FileList::Filter::ByEmailDate.new(files, date).get
FileList::Filter::ByEmailRecipient.new(files, recipient).get

f = FileList::Filter::ByEmailSubject.new(FileList.get("*.*"), "binding")
puts f.get

=end
