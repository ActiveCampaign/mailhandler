# Base filtering class, which is used for reading list of all files based on passed pattern.
# Patterns to be used can be checked here: http://ruby-doc.org/core-1.9.3/Dir.html

module MailHandler

  module Receiving

    module FileList

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

    end

    module FilterFiles

      class Base

        def get(files, content)

          filter_files(files, content)

        end

        protected

        def filter_files(files, content)

          files.select do |file|

            begin

              content_in_file?(file, content)

            rescue

              false

            end

          end

        end

        def content_in_file?(file, content)

          raise StandardError, 'Needs to be implemented'

        end

        def read_file(file)

          File.read(file)

        end

      end

      class BySubject < Base

        private

        def content_in_file?(file, content)

          read_file(file).include? content

        end

      end

    end

  end

end
