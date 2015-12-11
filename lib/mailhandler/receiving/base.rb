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

      DEFAULT_SEARCH_OPTIONS = [

          :archive
      ]

      def initialize

        base_search_options
        reset_found_emails

      end

      def find(options)

        raise StandardError, 'Method not implemented'

      end

      def search_result

        !found_emails.empty?

      end

      def reset_found_emails

        @found_emails = []

      end

      protected

      def base_search_options

        # Default number of email results to return, and whether to archive emails.
        @search_options = {:count => 50, :archive => false}

      end

      def verify_and_set_search_options(options)

        base_search_options
        validate_used_options(options)

        @search_options = search_options.merge options
        reset_found_emails

      end

      def validate_used_options(options)

        unless (options.keys - AVAILABLE_SEARCH_OPTIONS).empty?
          raise StandardError, "#{(options.keys - AVAILABLE_SEARCH_OPTIONS)} - Incorrect search option values, options are #{AVAILABLE_SEARCH_OPTIONS}"
        end

      end

    end

  end

end
