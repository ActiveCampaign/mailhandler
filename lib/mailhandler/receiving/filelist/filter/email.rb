# frozen_string_literal: true

require 'mail'
require_relative 'base'

module MailHandler
  module Receiving
    class FileList
      module Filter
        # filtering file content by its email properties
        class Email < Base
          def initialize(files)
            @fast_check = true
            super(files)
          end

          protected

          def read_email_from_file(file)
            Mail.read(file)
          end

          def meets_expectation?(file)
            # fast content checks search for content by file reading
            # slow content checks search for content by reconstructing email from file and then searching for content
            fast_check ? check_content_fast(file) : check_content_slow(file)
          end

          def check_content_fast(_file)
            raise MailHandler::InterfaceError, 'Interface not implemented.'
          end

          def check_content_slow(_file)
            raise MailHandler::InterfaceError, 'Interface not implemented.'
          end
        end

        # filter by email content
        class ByEmailContent < Email
          def initialize(files, content)
            super(files)
            @content = content
          end

          private

          def check_content_fast(file)
            read_file(file).include? @content
          end

          def check_content_slow(file)
            email = read_email_from_file(file)

            if email.multipart?

              email.text_part.decoded.include?(@content) || email.html_part.decoded.include?(@content)

            else

              email.decoded.include? @content

            end
          end
        end

        # filter by email subject
        class ByEmailSubject < ByEmailContent
          private

          def check_content_fast(file)
            read_file(file).include? @content
          end

          def check_content_slow(file)
            read_email_from_file(file).subject.to_s.include? @content
          end
        end

        # filter by email recipient
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
