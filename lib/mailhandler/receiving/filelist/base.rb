# Base filtering class, which is used for reading list of all files based on passed pattern.
# Patterns to be used can be checked here: http://ruby-doc.org/core-1.9.3/Dir.html

module MailHandler

  module Receiving

    class FileList

      def self.get(pattern)

        Dir.glob(pattern).map { |file| File.absolute_path(file) }

      end

      def self.sort(files)

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
