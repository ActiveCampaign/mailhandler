require 'fileutils'

# Base filtering class, which is used for reading list of all files based on passed pattern.
# Patterns to be used can be checked here: http://ruby-doc.org/core-1.9.3/Dir.html
module MailHandler
  # namespace
  module Receiving
    # namespace
    module FileHandling
      # if file exists, execute file operation, otherwise return default return value when it doesn't
      def access_file(file, default_return = false)
        if File.exist? file

          begin
            yield
          rescue StandardError => e
            raise e if File.exist? file

            default_return
          end

        else

          default_return

        end
      end
    end

    # base filelist
    class FileList
      include FileHandling

      def get(pattern)
        Dir.glob(pattern)
      end

      def sort(files)
        swapped = true
        j = 0

        while swapped
          swapped = false
          j += 1

          (files.size - j).times do |i|
            next unless swap_files?(files[i], files[i + 1])

            tmp = files[i]
            files[i] = files[i + 1]
            files[i + 1] = tmp
            swapped = true
          end
        end

        files
      end

      private

      def swap_files?(current_file, next_file)
        file1 = get_file(current_file)
        file2 = get_file(next_file)
        file1 && file2 && file1 < file2
      end

      def get_file(file)
        access_file(file, false) { File.new(file).ctime }
      end
    end
  end
end

#
# TEST EXAMPLE
#
# FileList.get('*.*')
# FileList::Filter::ByEmailSubject.new(files,'subject').get
# FileList::Filter::ByEmailContent.new(files,'content').get
# FileList::Filter::ByEmailDate.new(files, date).get
# FileList::Filter::ByEmailRecipient.new(files, recipient).get
#
# f = FileList::Filter::ByEmailSubject.new(FileList.get("*.*"), "binding")
# puts f.get
#
