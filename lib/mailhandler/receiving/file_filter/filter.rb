require 'fileutils'
require_relative 'base'

module MailHandler

  module Receiving

    module Filter

      class ContentBase < Base

        def initialize(content)

          @content = content.to_s

        end

        protected

        def read_email(content)

          Mail.read_from_string(content)

        end

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

          # TODO: add UTF support
          # string need to be read and converted
          # read_email(file_content).subject.include?(@content) - 10x slower, use something else for reading
          # Mail::Encodings.unquote_and_convert_to(content, "UTF-8") - 6x slower
          File.read(file).include? @content

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

  end

end
