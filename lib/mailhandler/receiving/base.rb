module MailHandler

  module Receiving

    #
    # Email receiving checker main class.
    # @see MailHandler::Receiving::FolderChecker for example for one of implemented checkers.
    #
    class Checker

      attr_accessor :search_options,
                    :found_emails

      AVAILABLE_SEARCH_OPTIONS = [

          :by_subject,
          :by_content,
          :by_date,
          :by_recipient,
          :count,
          :archive

      ]

      def initialize

        # Default number of email results to return, and whether to archive emails.
        @search_options = {:count => 50, :archive => false}
        @found_emails = []

      end

      def find(options)

        raise StandardError, 'Method not implemented'

      end

      def search_result

        !found_emails.empty?

      end

      protected

      def verify_and_set_search_options(options)

        unless (options.keys - AVAILABLE_SEARCH_OPTIONS).empty?
          raise StandardError, "#{(options.keys - AVAILABLE_SEARCH_OPTIONS)} - Incorrect search option values, options are #{AVAILABLE_SEARCH_OPTIONS}"
        end

        @search_options = search_options.merge options

      end

    end

  end

end
