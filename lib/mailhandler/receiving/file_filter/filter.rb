require 'fileutils'
require_relative 'base'

module MailHandler

  module Receiving

    class FileList

      module Filter

        class Base

          attr_accessor :files

          def initialize(files)

            @files=files

          end

          def get

            files.select { |file| ignore_exception { meets_expectation?(file) } }

          end

          protected

          def meet_expectation?(file)

            raise StandardError, 'Needs to be implemented.'

          end

          def read_file(file)

            # TODO: add UTF support
            # string need to be read and converted
            # read_email(file_content).subject.include?(@content) - 10x slower, use something else for reading
            # Mail::Encodings.unquote_and_convert_to(content, "UTF-8") - 6x slower
            File.read(file)

          end

          private

          def ignore_exception

            begin

              yield

            rescue

              false

            end

          end

        end

        class ByDate < Base

          def initialize(files, date)

            super(files)
            @date = date

          end

          private

          def meets_expectation?(file)

            file = File.new(file)
            (file != nil)? file.ctime > @date : false

          end

        end

        class Email < Base

          def initialize(files)

            super(files)

          end

          protected

          def read_email_from_file(file)

            Mail.read(file)

          end

        end

        class ByEmailContent < Email

          def initialize(files, content)

            super(files)
            @content = content

          end

          protected

          def meets_expectation?(file)

            read_file(file).include? @content

          end

        end

        class ByEmailSubject < ByEmailContent ; end

        class ByEmailRecipient < Email

          def initialize(files, recipient)

            super(files)
            @recipient = recipient

          end

          private

          def meets_expectation?(file)

            read_email_from_file(file)[@recipient.keys.first].to_s.include? @recipient.values.first

          end

        end

      end

    end

  end

end
