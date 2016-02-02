require_relative '../base'
require_relative '../../../errors'

module MailHandler

  module Receiving

    class FileList

      module Filter

        class Base

          attr_accessor :files, :fast_check

          def initialize(files)

            @files=files

          end

          def get

            files.select { |file| ignore_exception { meets_expectation?(file) } }

          end

          protected

          def meet_expectation?(file)

            raise MailHandler::InterfaceError, 'Interface not implemented.'

          end

          def read_file(file)

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

            (File.exists? file)? (File.ctime file) > @date : false

          end

        end

      end

    end

  end

end
