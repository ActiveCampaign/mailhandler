require 'mail'
require_relative 'base'

module MailHandler

  module Receiving

    class FileList

      module Filter

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



          end

          private

          def search_fast

            read_file(file).include? @content

          end

          def search_slow


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
