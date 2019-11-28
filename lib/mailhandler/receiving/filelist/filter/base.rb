# frozen_string_literal: true

require_relative '../base'
require_relative '../../../errors'

module MailHandler
  module Receiving
    # namespace
    class FileList
      # namespace
      module Filter
        # base filter for files
        class Base
          attr_accessor :files, :fast_check

          def initialize(files)
            @files = files
          end

          def get
            files.select { |file| ignore_exception { meets_expectation?(file) } }
          end

          protected

          def meet_expectation?(_file)
            raise MailHandler::InterfaceError, 'Interface not implemented.'
          end

          def read_file(file)
            File.read(file)
          end

          private

          def ignore_exception
            yield
          rescue StandardError
            false
          end
        end

        module ByDate
          # filter files by date
          class BaseDate < Base
            def initialize(files, date)
              super(files)
              @date = date
            end
          end

          # since date filter
          class Since < BaseDate
            private

            def meets_expectation?(file)
              File.exist?(file) ? (File.ctime file) > @date : false
            end
          end

          # before date filter
          class Before < Base
            private

            def meets_expectation?(file)
              File.exist?(file) ? (File.ctime file) < @date : false
            end
          end
        end
      end
    end
  end
end
